import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/inbox_transaction.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/inbox_repository.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../providers/subscriptions_provider.dart';
import '../datasources/remote/inbox_remote_datasource.dart';
import '../models/inbox_transaction_model.dart';

/// Implementation of [InboxRepository] handling Firestore staging queries,
/// smart local account/category resolution, automatic subscription tracking,
/// SQLite atomic insertion, and Firestore ACK.
class InboxRepositoryImpl implements InboxRepository {
  final InboxRemoteDataSource _remoteDataSource;
  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;
  final SubscriptionRepository? _subscriptionRepository;

  InboxRepositoryImpl({
    required InboxRemoteDataSource remoteDataSource,
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
    SubscriptionRepository? subscriptionRepository,
  })  : _remoteDataSource = remoteDataSource,
        _transactionRepository = transactionRepository,
        _accountRepository = accountRepository,
        _categoryRepository = categoryRepository,
        _subscriptionRepository = subscriptionRepository;

  @override
  Future<List<InboxTransaction>> getPendingTransactions({String userId = 'user_default'}) async {
    return await _remoteDataSource.getPendingTransactions(userId: userId);
  }

  @override
  Future<int> syncPendingTransactions({String userId = 'user_default'}) async {
    final List<InboxTransactionModel> pendingList =
        List.of(await _remoteDataSource.getPendingTransactions(userId: userId));

    if (pendingList.isEmpty) return 0;

    final List<Account> accounts = await _accountRepository.getAccounts(includeArchived: false);
    final List<Category> categories = await _categoryRepository.getCategories();
    final List<Subscription> activeSubscriptions =
        await _subscriptionRepository?.getSubscriptions(isActive: true) ?? [];

    int syncedCount = 0;

    for (final InboxTransactionModel item in pendingList) {
      try {
        final String localTxId = 'tx_gmail_${item.id}';

        // Check if already exists in SQLite (Idempotency)
        final Transaction? existing = await _transactionRepository.getTransactionById(localTxId);
        if (existing != null) {
          // Already in SQLite, just ACK Firestore
          await _remoteDataSource.markAsSynced(item.id, userId: userId);
          syncedCount++;
          continue;
        }

        // 1. Resolve Account using multi-token and root brand matching
        final Account? resolvedAccount = _matchAccount(item, accounts);
        if (resolvedAccount == null) {
          // Cannot persist without any account existing
          continue;
        }

        // 2. Check for matching active Subscription
        final Subscription? matchedSub = _matchSubscription(item, activeSubscriptions);

        // 3. Resolve Transaction Type (with incoming transfer heuristic detection)
        final TransactionType txType = _resolveTransactionType(item);

        // 4. Resolve Category conforming to transaction type
        final Category? resolvedCategory = matchedSub != null
            ? _categoryRepositoryById(matchedSub.categoryId, categories) ?? _matchCategory(item, categories, txType)
            : _matchCategory(item, categories, txType);

        final DateTime now = DateTime.now().toUtc();

        final String description = matchedSub != null
            ? '${matchedSub.name} (Subscription Payment)'
            : (item.merchant.isNotEmpty ? item.merchant : item.bankName);

        final Transaction newTx = Transaction(
          id: localTxId,
          accountId: resolvedAccount.id,
          toAccountId: null,
          categoryId: resolvedCategory?.id,
          amountCents: item.amountCents > 0 ? item.amountCents : 1,
          originalCurrency: item.currency,
          originalAmountCents: item.amountCents > 0 ? item.amountCents : 1,
          exchangeRate: 1.0,
          type: txType,
          description: description,
          transactionDate: item.transactionDate.toUtc(),
          createdAt: now,
          updatedAt: now,
        );

        // 5. Persist to SQLite (automatically updates account balance)
        await _transactionRepository.createTransaction(newTx);

        // 6. If matched to a subscription, automatically advance its next due date
        if (matchedSub != null && _subscriptionRepository != null) {
          try {
            final DateTime nextDue = SubscriptionsProvider.calculateNextDueDate(
              matchedSub.nextDueDate,
              matchedSub.frequency,
              billingDay: matchedSub.billingDay,
            );
            await _subscriptionRepository.updateNextDueDate(matchedSub.id, nextDue);
          } catch (_) {}
        }

        // 7. ACK remote staging
        await _remoteDataSource.markAsSynced(item.id, userId: userId);
        syncedCount++;
      } catch (e) {
        // Continue with next transaction on individual error
      }
    }

    return syncedCount;
  }

  @override
  Future<void> markAsSynced(String transactionId, {String userId = 'user_default'}) async {
    await _remoteDataSource.markAsSynced(transactionId, userId: userId);
  }

  @override
  Future<void> markAsDiscarded(String transactionId, {String userId = 'user_default'}) async {
    await _remoteDataSource.markAsDiscarded(transactionId, userId: userId);
  }

  /// Resolves the best matching local account based on mask digits, root brand tokens, and account type.
  Account? _matchAccount(InboxTransaction item, List<Account> accounts) {
    if (accounts.isEmpty) return null;

    final String digitsOnly = item.accountMask.replaceAll(RegExp(r'\D'), '');

    // 1. High priority: Match by mask digits (e.g. *4892 -> account name containing "4892")
    if (digitsOnly.length >= 2) {
      for (final Account acc in accounts) {
        if (acc.name.contains(digitsOnly)) {
          return acc;
        }
      }
    }

    final String bankRaw = item.bankName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final bool isCredit = item.accountType == 'credit_card';

    bool matchesBrand(String accountName, String bankName) {
      final String accNorm = accountName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (accNorm.isEmpty || bankName.isEmpty) return false;

      // Bidirectional containment: "rappicard".contains("rappi") OR "rappi".contains("rappicard")
      if (accNorm.contains(bankName) || bankName.contains(accNorm)) {
        return true;
      }

      // LatAm & Global bank brand root aliases
      const commonRoots = [
        'rappi', 'bancolombia', 'nu', 'nequi', 'davivienda', 'bbva',
        'falabella', 'scotia', 'itau', 'chase', 'bofa', 'wells', 'citi',
        'mercado', 'uala', 'daviplata', 'popular', 'occidente', 'bogota', 'santander'
      ];
      for (final root in commonRoots) {
        if (accNorm.contains(root) && bankName.contains(root)) {
          return true;
        }
      }
      return false;
    }

    // 2. High priority: Brand match + Account Type match (e.g. RappiCard -> Rappi Credit Card)
    for (final Account acc in accounts) {
      if (matchesBrand(acc.name, bankRaw)) {
        if (isCredit && acc.type == AccountType.creditCard) {
          return acc;
        }
        if (!isCredit && (acc.type == AccountType.bank || acc.type == AccountType.digitalWallet || acc.type == AccountType.cash)) {
          return acc;
        }
      }
    }

    // 3. Medium priority: Brand match regardless of type
    for (final Account acc in accounts) {
      if (matchesBrand(acc.name, bankRaw)) {
        return acc;
      }
    }

    // 4. Low priority: If credit card and there is only ONE credit card in the account list
    if (isCredit) {
      final creditAccounts = accounts.where((a) => a.type == AccountType.creditCard).toList();
      if (creditAccounts.length == 1) {
        return creditAccounts.first;
      }
    }

    // 5. Fallback: First active account
    return accounts.first;
  }

  /// Checks if the transaction corresponds to a registered active subscription (e.g., Microsoft, Netflix, Spotify).
  /// Enforces multi-factor verification: name/brand match, tight date window (±4 days), and amount tolerance (±15%).
  Subscription? _matchSubscription(InboxTransaction item, List<Subscription> subscriptions) {
    if (subscriptions.isEmpty) return null;

    final String merchantNorm = item.merchant.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
    if (merchantNorm.isEmpty) return null;

    for (final Subscription sub in subscriptions) {
      final String subNorm = sub.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
      if (subNorm.isEmpty) continue;

      // 1. Name / Brand match
      final bool nameMatches = merchantNorm.contains(subNorm) || subNorm.contains(merchantNorm);
      if (!nameMatches) continue;

      // 2. Amount tolerance check (tight 15% margin for taxes / slight rate fluctuations)
      if (sub.amountCents > 0) {
        if (item.currency.toUpperCase() == sub.currency.toUpperCase()) {
          final double diffRatio = (item.amountCents - sub.amountCents).abs() / sub.amountCents;
          if (diffRatio > 0.15) {
            continue; // Amount mismatch: treated as standard transaction
          }
        }
      }

      // 3. Date window check (within ±4 days of nextDueDate or billingDay)
      final int daysDiff = item.transactionDate.difference(sub.nextDueDate).inDays.abs();
      final int dayOfMonthDiff = (item.transactionDate.day - sub.billingDay).abs();
      final bool dateMatches = daysDiff <= 4 || dayOfMonthDiff <= 3 || (31 - dayOfMonthDiff) <= 3;
      if (!dateMatches) {
        continue; // Date outside subscription billing cycle: treated as standard transaction
      }

      return sub;
    }
    return null;
  }

  Category? _categoryRepositoryById(String id, List<Category> categories) {
    for (final Category cat in categories) {
      if (cat.id == id) return cat;
    }
    return null;
  }

  /// Resolves whether the transaction is an income or an expense, using explicit flags
  /// and heuristic natural-language detection for bank transfer receipts, deposits, and refunds.
  TransactionType _resolveTransactionType(InboxTransaction item) {
    if (item.isIncome) return TransactionType.income;

    final String text = '${item.merchant} ${item.categorySuggestion} ${item.bankName}'.toLowerCase();

    const incomeKeywords = [
      'recibiste',
      'recibido',
      'recibida',
      'te transfirieron',
      'te consignaron',
      'abono',
      'deposito',
      'depósito',
      'consignacion',
      'consignación',
      'transferencia recibida',
      'transferencia de',
      'devolucion',
      'devolución',
      'cashback',
      'reembolso',
      'nomina',
      'nómina',
      'salario',
      'sueldo',
      'received',
      'deposit',
      'refund',
      'payroll',
      'salary',
    ];

    for (final kw in incomeKeywords) {
      if (text.contains(kw)) {
        return TransactionType.income;
      }
    }

    return TransactionType.expense;
  }

  /// Resolves the best matching category from SQLite categories conforming to transaction type.
  Category? _matchCategory(InboxTransaction item, List<Category> categories, TransactionType txType) {
    if (categories.isEmpty) return null;

    final bool isIncome = txType == TransactionType.income;
    final List<Category> typedCategories =
        categories.where((c) => isIncome ? c.isIncome : c.isExpense).toList();
    final List<Category> searchPool = typedCategories.isNotEmpty ? typedCategories : categories;

    final String suggestion = item.categorySuggestion.trim().toLowerCase();

    // 1. Match exact name in typed pool
    for (final Category cat in searchPool) {
      if (cat.name.toLowerCase() == suggestion) {
        return cat;
      }
    }

    // 2. Match partial name in typed pool
    for (final Category cat in searchPool) {
      if (cat.name.toLowerCase().contains(suggestion) || suggestion.contains(cat.name.toLowerCase())) {
        return cat;
      }
    }

    // 3. Fallback to default other category of the matching type
    final String defaultFallbackId = isIncome ? 'cat_default_other_income' : 'cat_default_other_expense';
    for (final Category cat in categories) {
      if (cat.id == defaultFallbackId) return cat;
    }

    return searchPool.first;
  }
}
