import 'package:flutter/foundation.dart' hide Category;
import '../domain/entities/category.dart';
import '../domain/entities/transaction.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/transaction_repository.dart';
import 'accounts_provider.dart';

/// Reactive provider managing transactions, categories, and financial filtering.
class TransactionsProvider extends ChangeNotifier {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  List<Transaction> _transactions = [];
  List<Transaction> _recentTransactions = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter state
  String? _selectedAccountId;
  String? _selectedCategoryId;
  TransactionType? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  TransactionsProvider({
    required TransactionRepository transactionRepository,
    required CategoryRepository categoryRepository,
  }) : _transactionRepository = transactionRepository,
       _categoryRepository = categoryRepository;

  // Getters
  List<Transaction> get transactions => List.unmodifiable(_transactions);
  List<Transaction> get recentTransactions =>
      List.unmodifiable(_recentTransactions);
  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? get selectedAccountId => _selectedAccountId;
  String? get selectedCategoryId => _selectedCategoryId;
  TransactionType? get selectedType => _selectedType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;

  List<Category> get expenseCategories =>
      _categories.where((c) => c.isExpense).toList();

  List<Category> get incomeCategories =>
      _categories.where((c) => c.isIncome).toList();

  /// Total income in minor units (cents) for the currently filtered transactions.
  int get totalIncomeCents => _transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amountCents);

  /// Total expenses in minor units (cents) for the currently filtered transactions.
  int get totalExpenseCents => _transactions
      .where((t) => t.isExpense)
      .fold(0, (sum, t) => sum + t.amountCents);

  /// Net cash flow ($Total Income - Total Expenses$) for filtered transactions.
  int get netCashFlowCents => totalIncomeCents - totalExpenseCents;

  /// Looks up a category from cached categories by its ID.
  Category? getCategoryById(String? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Initializes provider state by fetching categories, recent transactions, and filtered list.
  Future<void> initialize() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await fetchCategories(notify: false);
      await fetchRecentTransactions(notify: false);
      await fetchTransactions(notify: false);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Fetches all transaction categories.
  Future<void> fetchCategories({bool notify = true}) async {
    try {
      _categories = await _categoryRepository.getCategories();
      if (notify) notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
      if (notify) notifyListeners();
    }
  }

  /// Fetches transactions applying active filter parameters.
  Future<void> fetchTransactions({bool notify = true}) async {
    try {
      _transactions = await _transactionRepository.getTransactions(
        accountId: _selectedAccountId,
        categoryId: _selectedCategoryId,
        type: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      if (notify) notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load transactions: $e';
      if (notify) notifyListeners();
    }
  }

  /// Fetches the top recent transactions for quick overview.
  Future<void> fetchRecentTransactions({
    int limit = 10,
    bool notify = true,
  }) async {
    try {
      _recentTransactions = await _transactionRepository.getRecentTransactions(
        limit: limit,
      );
      if (notify) notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load recent transactions: $e';
      if (notify) notifyListeners();
    }
  }

  /// Creates a new transaction, persists to database, and triggers account balance updates.
  Future<void> addTransaction(
    Transaction transaction, {
    AccountsProvider? accountsProvider,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _transactionRepository.createTransaction(transaction);
      await accountsProvider?.loadAccounts();
      await fetchRecentTransactions(notify: false);
      await fetchTransactions(notify: false);
    } catch (e) {
      _errorMessage = 'Failed to record transaction: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing transaction and synchronizes account balances.
  Future<void> updateTransaction(
    Transaction transaction, {
    AccountsProvider? accountsProvider,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _transactionRepository.updateTransaction(transaction);
      await accountsProvider?.loadAccounts();
      await fetchRecentTransactions(notify: false);
      await fetchTransactions(notify: false);
    } catch (e) {
      _errorMessage = 'Failed to update transaction: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a transaction and reverses its account balance modification.
  Future<void> deleteTransaction(
    String id, {
    AccountsProvider? accountsProvider,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _transactionRepository.deleteTransaction(id);
      await accountsProvider?.loadAccounts();
      await fetchRecentTransactions(notify: false);
      await fetchTransactions(notify: false);
    } catch (e) {
      _errorMessage = 'Failed to delete transaction: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a custom user category.
  Future<void> addCategory(Category category) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _categoryRepository.createCategory(category);
      await fetchCategories(notify: false);
    } catch (e) {
      _errorMessage = 'Failed to create category: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates a category.
  Future<void> updateCategory(Category category) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _categoryRepository.updateCategory(category);
      await fetchCategories(notify: false);
    } catch (e) {
      _errorMessage = 'Failed to update category: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a category.
  Future<void> deleteCategory(String id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _categoryRepository.deleteCategory(id);
      await fetchCategories(notify: false);
    } catch (e) {
      _errorMessage = 'Failed to delete category: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Filter setters
  void setFilterAccount(String? accountId) {
    if (_selectedAccountId != accountId) {
      _selectedAccountId = accountId;
      fetchTransactions();
    }
  }

  void setFilterCategory(String? categoryId) {
    if (_selectedCategoryId != categoryId) {
      _selectedCategoryId = categoryId;
      fetchTransactions();
    }
  }

  void setFilterType(TransactionType? type) {
    if (_selectedType != type) {
      _selectedType = type;
      fetchTransactions();
    }
  }

  void setFilterDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    fetchTransactions();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchTransactions();
  }

  void clearFilters() {
    _selectedAccountId = null;
    _selectedCategoryId = null;
    _selectedType = null;
    _startDate = null;
    _endDate = null;
    _searchQuery = '';
    fetchTransactions();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
