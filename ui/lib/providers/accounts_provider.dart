import 'package:flutter/foundation.dart';
import '../domain/entities/account.dart';
import '../domain/repositories/account_repository.dart';

/// Provider managing the reactive lifecycle and financial aggregations of user accounts.
class AccountsProvider with ChangeNotifier {
  final AccountRepository _repository;

  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _errorMessage;

  AccountsProvider({required AccountRepository repository})
    : _repository = repository;

  List<Account> get accounts => List.unmodifiable(_accounts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Active asset accounts (bank accounts, digital wallets, cash).
  List<Account> get assetAccounts =>
      _accounts.where((a) => !a.isCreditCard && !a.isArchived).toList();

  /// Active liability accounts (credit cards with revolving debt).
  List<Account> get creditCardAccounts =>
      _accounts.where((a) => a.isCreditCard && !a.isArchived).toList();

  /// Soft-archived accounts.
  List<Account> get archivedAccounts =>
      _accounts.where((a) => a.isArchived).toList();

  /// Total liquid and cash assets in integer cents.
  int get totalAssetsCents =>
      assetAccounts.fold<int>(0, (sum, a) => sum + a.balanceCents);

  /// Total revolving credit card debt in integer cents.
  int get totalLiabilitiesCents =>
      creditCardAccounts.fold<int>(0, (sum, a) => sum + a.balanceCents);

  /// Real-time Net Worth (Total Assets - Total Liabilities) in integer cents.
  int get netWorthCents => totalAssetsCents - totalLiabilitiesCents;

  /// Aggregate credit limit across all active credit cards.
  int get totalCreditLimitCents =>
      creditCardAccounts.fold<int>(0, (sum, a) => sum + a.creditLimitCents);

  /// Aggregate available revolving credit in integer cents.
  int get totalAvailableCreditCents =>
      (totalCreditLimitCents - totalLiabilitiesCents).clamp(
        0,
        totalCreditLimitCents,
      );

  /// Overall revolving credit utilization rate between 0.0 and 1.0.
  double get overallCreditUtilization => totalCreditLimitCents > 0
      ? (totalLiabilitiesCents / totalCreditLimitCents).clamp(0.0, 1.0)
      : 0.0;

  /// Loads accounts from repository.
  Future<void> loadAccounts({bool includeArchived = true}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _accounts = await _repository.getAccounts(
        includeArchived: includeArchived,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a new account and updates local state.
  Future<void> addAccount(Account account) async {
    _setLoading(true);
    try {
      await _repository.createAccount(account);
      _accounts.add(account);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing account and updates local state.
  Future<void> updateAccount(Account account) async {
    _setLoading(true);
    try {
      await _repository.updateAccount(account);
      final int index = _accounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        _accounts[index] = account;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes an account by [id].
  Future<void> deleteAccount(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteAccount(id);
      _accounts.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Adjusts the balance of an account directly.
  Future<void> adjustBalance(String id, int newBalanceCents) async {
    _setLoading(true);
    try {
      await _repository.adjustBalance(id, newBalanceCents);
      final int index = _accounts.indexWhere((a) => a.id == id);
      if (index != -1) {
        _accounts[index] = _accounts[index].copyWith(
          balanceCents: newBalanceCents,
          updatedAt: DateTime.now().toUtc(),
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Archives or unarchives an account.
  Future<void> toggleArchive(String id, bool isArchived) async {
    _setLoading(true);
    try {
      await _repository.setArchived(id, isArchived);
      final int index = _accounts.indexWhere((a) => a.id == id);
      if (index != -1) {
        _accounts[index] = _accounts[index].copyWith(
          isArchived: isArchived,
          updatedAt: DateTime.now().toUtc(),
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Finds an account by its [id] from in-memory cached state.
  Account? getAccountById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
