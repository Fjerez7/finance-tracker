import '../entities/account.dart';

/// Abstract contract for account data operations.
abstract class AccountRepository {
  /// Retrieves accounts from local storage.
  /// If [includeArchived] is false, only active accounts are returned.
  Future<List<Account>> getAccounts({bool includeArchived = false});

  /// Retrieves a single account by [id]. Returns null if not found.
  Future<Account?> getAccountById(String id);

  /// Creates a new account in local storage.
  Future<void> createAccount(Account account);

  /// Updates an existing account's details.
  Future<void> updateAccount(Account account);

  /// Deletes an account from local storage.
  /// Note: Fails if transactions reference this account due to foreign key constraints.
  Future<void> deleteAccount(String id);

  /// Adjusts the balance of an account directly.
  Future<void> adjustBalance(String id, int newBalanceCents);

  /// Archives or unarchives an account.
  Future<void> setArchived(String id, bool isArchived);
}
