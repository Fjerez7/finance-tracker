import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/repositories/account_repository.dart';
import 'package:finance_tracker/providers/accounts_provider.dart';

/// Fake in-memory implementation of AccountRepository for fast unit testing.
class FakeAccountRepository implements AccountRepository {
  final List<Account> _storage = [];

  @override
  Future<List<Account>> getAccounts({bool includeArchived = false}) async {
    if (includeArchived) return List.from(_storage);
    return _storage.where((a) => !a.isArchived).toList();
  }

  @override
  Future<Account?> getAccountById(String id) async {
    try {
      return _storage.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createAccount(Account account) async {
    _storage.add(account);
  }

  @override
  Future<void> updateAccount(Account account) async {
    final int index = _storage.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _storage[index] = account;
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    _storage.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> adjustBalance(String id, int newBalanceCents) async {
    final int index = _storage.indexWhere((a) => a.id == id);
    if (index != -1) {
      _storage[index] = _storage[index].copyWith(balanceCents: newBalanceCents);
    }
  }

  @override
  Future<void> setArchived(String id, bool isArchived) async {
    final int index = _storage.indexWhere((a) => a.id == id);
    if (index != -1) {
      _storage[index] = _storage[index].copyWith(isArchived: isArchived);
    }
  }
}

void main() {
  late FakeAccountRepository fakeRepo;
  late AccountsProvider provider;

  final DateTime now = DateTime.parse('2026-09-04T20:00:00.000Z');

  final Account checking = Account(
    id: 'acc-1',
    name: 'Checking',
    type: AccountType.bank,
    balanceCents: 500000, // $5,000.00 asset
    currency: 'USD',
    colorHex: '#4CAF50',
    iconName: 'account_balance',
    isArchived: false,
    createdAt: now,
    updatedAt: now,
  );

  final Account wallet = Account(
    id: 'acc-2',
    name: 'Cash Wallet',
    type: AccountType.cash,
    balanceCents: 15000, // $150.00 asset
    currency: 'USD',
    colorHex: '#8BC34A',
    iconName: 'wallet',
    isArchived: false,
    createdAt: now,
    updatedAt: now,
  );

  final Account creditCard = Account(
    id: 'acc-3',
    name: 'Visa Card',
    type: AccountType.creditCard,
    balanceCents: 80000, // $800.00 liability (debt)
    creditLimitCents: 200000, // $2,000.00 limit
    currency: 'USD',
    colorHex: '#2196F3',
    iconName: 'credit_card',
    isArchived: false,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    fakeRepo = FakeAccountRepository();
    provider = AccountsProvider(repository: fakeRepo);
  });

  group('AccountsProvider State & Financial Calculations', () {
    test(
      'computes total assets, liabilities, and Net Worth in real time',
      () async {
        await provider.addAccount(checking);
        await provider.addAccount(wallet);
        await provider.addAccount(creditCard);

        expect(provider.assetAccounts.length, equals(2));
        expect(provider.creditCardAccounts.length, equals(1));

        // Total Assets: 500000 + 15000 = 515000 cents ($5,150.00)
        expect(provider.totalAssetsCents, equals(515000));

        // Total Liabilities: 80000 cents ($800.00)
        expect(provider.totalLiabilitiesCents, equals(80000));

        // Net Worth: 515000 - 80000 = 435000 cents ($4,350.00)
        expect(provider.netWorthCents, equals(435000));

        // Credit limit and utilization
        expect(provider.totalCreditLimitCents, equals(200000));
        expect(
          provider.totalAvailableCreditCents,
          equals(120000),
        ); // 200000 - 80000
        expect(
          provider.overallCreditUtilization,
          equals(0.4),
        ); // 80000 / 200000 = 40%
      },
    );

    test(
      'updates state when account is modified or balance adjusted',
      () async {
        await provider.addAccount(checking);

        await provider.adjustBalance('acc-1', 600000);
        expect(provider.getAccountById('acc-1')?.balanceCents, equals(600000));
        expect(provider.totalAssetsCents, equals(600000));
        expect(provider.netWorthCents, equals(600000));
      },
    );

    test('archives and filters accounts correctly', () async {
      await provider.addAccount(checking);
      await provider.addAccount(wallet);

      await provider.toggleArchive('acc-2', true);

      expect(provider.assetAccounts.length, equals(1));
      expect(provider.archivedAccounts.length, equals(1));
      expect(
        provider.totalAssetsCents,
        equals(500000),
      ); // Excludes archived wallet
    });

    test('deletes account and updates Net Worth', () async {
      await provider.addAccount(checking);
      await provider.addAccount(creditCard);

      expect(provider.netWorthCents, equals(420000)); // 500000 - 80000

      await provider.deleteAccount('acc-3');
      expect(provider.creditCardAccounts.isEmpty, isTrue);
      expect(provider.totalLiabilitiesCents, equals(0));
      expect(provider.netWorthCents, equals(500000));
    });
  });
}
