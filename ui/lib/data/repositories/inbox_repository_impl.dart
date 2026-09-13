import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/inbox_transaction.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/inbox_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/remote/inbox_remote_datasource.dart';
import '../models/inbox_transaction_model.dart';

/// Implementation of [InboxRepository] handling Firestore staging queries,
/// smart local account/category resolution, SQLite atomic insertion, and Firestore ACK.
class InboxRepositoryImpl implements InboxRepository {
  final InboxRemoteDataSource _remoteDataSource;
  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;

  InboxRepositoryImpl({
    required InboxRemoteDataSource remoteDataSource,
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
  })  : _remoteDataSource = remoteDataSource,
        _transactionRepository = transactionRepository,
        _accountRepository = accountRepository,
        _categoryRepository = categoryRepository;

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

        // 1. Resolve Account
        final Account? resolvedAccount = _matchAccount(item, accounts);
        if (resolvedAccount == null) {
          // Cannot persist without any account existing
          continue;
        }

        // 2. Resolve Category
        final Category? resolvedCategory = _matchCategory(item, categories);

        // 3. Resolve Transaction Type
        final TransactionType txType = item.isIncome
            ? TransactionType.income
            : TransactionType.expense;

        final DateTime now = DateTime.now().toUtc();

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
          description: item.merchant.isNotEmpty ? item.merchant : item.bankName,
          transactionDate: item.transactionDate.toUtc(),
          createdAt: now,
          updatedAt: now,
        );

        // 4. Persist to SQLite (automatically updates account balance)
        await _transactionRepository.createTransaction(newTx);

        // 5. ACK remote staging
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

  /// Resolves the best matching local account based on mask, bank name, and type.
  Account? _matchAccount(InboxTransaction item, List<Account> accounts) {
    if (accounts.isEmpty) return null;

    final String digitsOnly = item.accountMask.replaceAll(RegExp(r'\D'), '');

    // 1. Match by mask digits (e.g. *4892 -> account containing "4892")
    if (digitsOnly.length >= 2) {
      for (final Account acc in accounts) {
        if (acc.name.contains(digitsOnly)) {
          return acc;
        }
      }
    }

    final String bankLower = item.bankName.toLowerCase();
    final bool isCredit = item.accountType == 'credit_card';

    // 2. Match by Bank Name + Account Type
    for (final Account acc in accounts) {
      final String accNameLower = acc.name.toLowerCase();
      if (accNameLower.contains(bankLower)) {
        if (isCredit && acc.type == AccountType.creditCard) {
          return acc;
        }
        if (!isCredit && (acc.type == AccountType.bank || acc.type == AccountType.digitalWallet)) {
          return acc;
        }
      }
    }

    // 3. Match by Bank Name only
    for (final Account acc in accounts) {
      if (acc.name.toLowerCase().contains(bankLower)) {
        return acc;
      }
    }

    // 4. Match by Account Type only
    if (isCredit) {
      for (final Account acc in accounts) {
        if (acc.type == AccountType.creditCard) return acc;
      }
    }

    // 5. Fallback to first active account
    return accounts.first;
  }

  /// Resolves the best matching category from SQLite categories.
  Category? _matchCategory(InboxTransaction item, List<Category> categories) {
    if (categories.isEmpty) return null;

    final String suggestion = item.categorySuggestion.trim().toLowerCase();

    // 1. Match exact name
    for (final Category cat in categories) {
      if (cat.name.toLowerCase() == suggestion) {
        return cat;
      }
    }

    // 2. Match partial name
    for (final Category cat in categories) {
      if (cat.name.toLowerCase().contains(suggestion) || suggestion.contains(cat.name.toLowerCase())) {
        return cat;
      }
    }

    // 3. Fallback to default other category
    final String defaultFallbackId = item.isIncome ? 'cat_default_other_income' : 'cat_default_other_expense';
    for (final Category cat in categories) {
      if (cat.id == defaultFallbackId) return cat;
    }

    return categories.first;
  }
}
