import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../../core/constants/database_constants.dart';

/// Singleton helper managing SQLite database lifecycle, schema migrations, and seeds.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  /// Optional factory and path override for testing (e.g. sqflite_common_ffi in-memory).
  DatabaseFactory? databaseFactoryOverride;
  String? databasePathOverride;

  DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  static Future<Database>? _initFuture;

  /// Returns the active SQLite database instance, initializing it if needed.
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _initFuture ??= initDatabase();
    _database = await _initFuture;
    return _database!;
  }

  /// Initializes the SQLite database.
  Future<Database> initDatabase() async {
    final String path;
    if (databasePathOverride != null) {
      path = databasePathOverride!;
    } else {
      final String dbPath = await getDatabasesPath();
      path = p.join(dbPath, DatabaseConstants.databaseName);
    }

    final DatabaseFactory factory = databaseFactoryOverride ?? databaseFactory;

    return await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: DatabaseConstants.databaseVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  /// Enforces SQLite foreign keys.
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  /// Creates tables, indexes, and seeds on initial database creation.
  Future<void> _onCreate(Database db, int version) async {
    final Batch batch = db.batch();

    // 1. Accounts Table
    batch.execute('''
      CREATE TABLE ${DatabaseConstants.tableAccounts} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colName} TEXT NOT NULL,
        ${DatabaseConstants.colAccountType} TEXT NOT NULL,
        ${DatabaseConstants.colBalanceCents} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.colCreditLimitCents} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.colCurrency} TEXT NOT NULL DEFAULT 'USD',
        ${DatabaseConstants.colColorHex} TEXT NOT NULL,
        ${DatabaseConstants.colIconName} TEXT NOT NULL,
        ${DatabaseConstants.colIsArchived} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.colCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colUpdatedAt} TEXT NOT NULL
      );
    ''');

    // 2. Categories Table
    batch.execute('''
      CREATE TABLE ${DatabaseConstants.tableCategories} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colName} TEXT NOT NULL,
        ${DatabaseConstants.colIconName} TEXT NOT NULL,
        ${DatabaseConstants.colColorHex} TEXT NOT NULL,
        ${DatabaseConstants.colCategoryType} TEXT NOT NULL,
        ${DatabaseConstants.colIsDefault} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.colCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colUpdatedAt} TEXT NOT NULL
      );
    ''');

    // 3. Transactions Table
    batch.execute('''
      CREATE TABLE ${DatabaseConstants.tableTransactions} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colAccountId} TEXT NOT NULL,
        ${DatabaseConstants.colToAccountId} TEXT,
        ${DatabaseConstants.colCategoryId} TEXT,
        ${DatabaseConstants.colAmountCents} INTEGER NOT NULL CHECK (${DatabaseConstants.colAmountCents} > 0),
        ${DatabaseConstants.colTransactionType} TEXT NOT NULL,
        ${DatabaseConstants.colDescription} TEXT NOT NULL DEFAULT '',
        ${DatabaseConstants.colTransactionDate} TEXT NOT NULL,
        ${DatabaseConstants.colCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DatabaseConstants.colAccountId}) REFERENCES ${DatabaseConstants.tableAccounts} (${DatabaseConstants.colId}) ON DELETE RESTRICT,
        FOREIGN KEY (${DatabaseConstants.colToAccountId}) REFERENCES ${DatabaseConstants.tableAccounts} (${DatabaseConstants.colId}) ON DELETE RESTRICT,
        FOREIGN KEY (${DatabaseConstants.colCategoryId}) REFERENCES ${DatabaseConstants.tableCategories} (${DatabaseConstants.colId}) ON DELETE SET NULL
      );
    ''');

    // 4. Subscriptions Table
    batch.execute('''
      CREATE TABLE ${DatabaseConstants.tableSubscriptions} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colName} TEXT NOT NULL,
        ${DatabaseConstants.colAmountCents} INTEGER NOT NULL CHECK (${DatabaseConstants.colAmountCents} > 0),
        ${DatabaseConstants.colFrequency} TEXT NOT NULL,
        ${DatabaseConstants.colAccountId} TEXT NOT NULL,
        ${DatabaseConstants.colCategoryId} TEXT NOT NULL,
        ${DatabaseConstants.colBillingDay} INTEGER NOT NULL CHECK (${DatabaseConstants.colBillingDay} >= 1 AND ${DatabaseConstants.colBillingDay} <= 31),
        ${DatabaseConstants.colNextDueDate} TEXT NOT NULL,
        ${DatabaseConstants.colAutoRegister} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.colIsActive} INTEGER NOT NULL DEFAULT 1,
        ${DatabaseConstants.colCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colUpdatedAt} TEXT NOT NULL,
        FOREIGN KEY (${DatabaseConstants.colAccountId}) REFERENCES ${DatabaseConstants.tableAccounts} (${DatabaseConstants.colId}) ON DELETE RESTRICT,
        FOREIGN KEY (${DatabaseConstants.colCategoryId}) REFERENCES ${DatabaseConstants.tableCategories} (${DatabaseConstants.colId}) ON DELETE RESTRICT
      );
    ''');

    // 5. Budgets Table
    batch.execute('''
      CREATE TABLE ${DatabaseConstants.tableBudgets} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colCategoryId} TEXT NOT NULL,
        ${DatabaseConstants.colMonth} INTEGER NOT NULL CHECK (${DatabaseConstants.colMonth} >= 1 AND ${DatabaseConstants.colMonth} <= 12),
        ${DatabaseConstants.colYear} INTEGER NOT NULL CHECK (${DatabaseConstants.colYear} >= 2000),
        ${DatabaseConstants.colLimitCents} INTEGER NOT NULL CHECK (${DatabaseConstants.colLimitCents} > 0),
        ${DatabaseConstants.colCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colUpdatedAt} TEXT NOT NULL,
        UNIQUE (${DatabaseConstants.colCategoryId}, ${DatabaseConstants.colMonth}, ${DatabaseConstants.colYear}),
        FOREIGN KEY (${DatabaseConstants.colCategoryId}) REFERENCES ${DatabaseConstants.tableCategories} (${DatabaseConstants.colId}) ON DELETE CASCADE
      );
    ''');

    // 6. Savings Goals Table
    batch.execute('''
      CREATE TABLE ${DatabaseConstants.tableSavingsGoals} (
        ${DatabaseConstants.colId} TEXT PRIMARY KEY,
        ${DatabaseConstants.colName} TEXT NOT NULL,
        ${DatabaseConstants.colTargetAmountCents} INTEGER NOT NULL CHECK (${DatabaseConstants.colTargetAmountCents} > 0),
        ${DatabaseConstants.colCurrentAmountCents} INTEGER NOT NULL DEFAULT 0 CHECK (${DatabaseConstants.colCurrentAmountCents} >= 0),
        ${DatabaseConstants.colTargetDate} TEXT,
        ${DatabaseConstants.colColorHex} TEXT NOT NULL,
        ${DatabaseConstants.colIconName} TEXT NOT NULL,
        ${DatabaseConstants.colIsCompleted} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseConstants.colCreatedAt} TEXT NOT NULL,
        ${DatabaseConstants.colUpdatedAt} TEXT NOT NULL
      );
    ''');

    // 7. Performance Indexes
    batch.execute(
      'CREATE INDEX idx_transactions_date ON ${DatabaseConstants.tableTransactions} (${DatabaseConstants.colTransactionDate} DESC);',
    );
    batch.execute(
      'CREATE INDEX idx_transactions_account ON ${DatabaseConstants.tableTransactions} (${DatabaseConstants.colAccountId});',
    );
    batch.execute(
      'CREATE INDEX idx_transactions_to_account ON ${DatabaseConstants.tableTransactions} (${DatabaseConstants.colToAccountId});',
    );
    batch.execute(
      'CREATE INDEX idx_transactions_category ON ${DatabaseConstants.tableTransactions} (${DatabaseConstants.colCategoryId});',
    );
    batch.execute(
      'CREATE INDEX idx_subscriptions_due_date ON ${DatabaseConstants.tableSubscriptions} (${DatabaseConstants.colNextDueDate} ASC);',
    );
    batch.execute(
      'CREATE INDEX idx_budgets_period ON ${DatabaseConstants.tableBudgets} (${DatabaseConstants.colYear}, ${DatabaseConstants.colMonth});',
    );
    batch.execute(
      'CREATE INDEX idx_accounts_archived ON ${DatabaseConstants.tableAccounts} (${DatabaseConstants.colIsArchived});',
    );

    // 8. Seed Default Categories into same transaction batch
    _seedDefaultCategories(batch);

    // Execute table, index creation, and category seeds atomically
    await batch.commit(noResult: true);
  }

  /// Migrations for future database schema versions.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future schema migrations when increasing databaseVersion
  }

  /// Populates the initial system categories into batch.
  void _seedDefaultCategories(Batch batch) {
    final String now = DateTime.now().toUtc().toIso8601String();

    final List<Map<String, dynamic>> defaultCategories = [
      // Expense Categories
      {
        DatabaseConstants.colId: 'cat_default_food',
        DatabaseConstants.colName: 'Food & Dining',
        DatabaseConstants.colIconName: 'restaurant',
        DatabaseConstants.colColorHex: '#FF5722',
        DatabaseConstants.colCategoryType: 'expense',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: 'cat_default_groceries',
        DatabaseConstants.colName: 'Groceries',
        DatabaseConstants.colIconName: 'shopping_cart',
        DatabaseConstants.colColorHex: '#4CAF50',
        DatabaseConstants.colCategoryType: 'expense',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: 'cat_default_transport',
        DatabaseConstants.colName: 'Transportation',
        DatabaseConstants.colIconName: 'directions_car',
        DatabaseConstants.colColorHex: '#2196F3',
        DatabaseConstants.colCategoryType: 'expense',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: 'cat_default_housing',
        DatabaseConstants.colName: 'Housing & Rent',
        DatabaseConstants.colIconName: 'home',
        DatabaseConstants.colColorHex: '#9C27B0',
        DatabaseConstants.colCategoryType: 'expense',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: 'cat_default_utilities',
        DatabaseConstants.colName: 'Utilities & Services',
        DatabaseConstants.colIconName: 'bolt',
        DatabaseConstants.colColorHex: '#FF9800',
        DatabaseConstants.colCategoryType: 'expense',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: 'cat_default_entertainment',
        DatabaseConstants.colName: 'Entertainment',
        DatabaseConstants.colIconName: 'movie',
        DatabaseConstants.colColorHex: '#E91E63',
        DatabaseConstants.colCategoryType: 'expense',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: 'cat_default_health',
        DatabaseConstants.colName: 'Health & Medical',
        DatabaseConstants.colIconName: 'local_hospital',
        DatabaseConstants.colColorHex: '#00BCD4',
        DatabaseConstants.colCategoryType: 'expense',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: 'cat_default_personal',
        DatabaseConstants.colName: 'Personal Care',
        DatabaseConstants.colIconName: 'spa',
        DatabaseConstants.colColorHex: '#8BC34A',
        DatabaseConstants.colCategoryType: 'expense',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: 'cat_default_shopping',
        DatabaseConstants.colName: 'Shopping',
        DatabaseConstants.colIconName: 'shopping_bag',
        DatabaseConstants.colColorHex: '#009688',
        DatabaseConstants.colCategoryType: 'expense',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: 'cat_default_subscriptions',
        DatabaseConstants.colName: 'Subscriptions & Bills',
        DatabaseConstants.colIconName: 'subscriptions',
        DatabaseConstants.colColorHex: '#673AB7',
        DatabaseConstants.colCategoryType: 'expense',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: 'cat_default_other_expense',
        DatabaseConstants.colName: 'Other Expenses',
        DatabaseConstants.colIconName: 'more_horiz',
        DatabaseConstants.colColorHex: '#607D8B',
        DatabaseConstants.colCategoryType: 'expense',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },

      // Income Categories
      {
        DatabaseConstants.colId: 'cat_default_salary',
        DatabaseConstants.colName: 'Salary & Payroll',
        DatabaseConstants.colIconName: 'payments',
        DatabaseConstants.colColorHex: '#4CAF50',
        DatabaseConstants.colCategoryType: 'income',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: 'cat_default_freelance',
        DatabaseConstants.colName: 'Freelance & Business',
        DatabaseConstants.colIconName: 'work',
        DatabaseConstants.colColorHex: '#2196F3',
        DatabaseConstants.colCategoryType: 'income',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: 'cat_default_investments',
        DatabaseConstants.colName: 'Investments & Returns',
        DatabaseConstants.colIconName: 'trending_up',
        DatabaseConstants.colColorHex: '#00BCD4',
        DatabaseConstants.colCategoryType: 'income',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
      {
        DatabaseConstants.colId: 'cat_default_other_income',
        DatabaseConstants.colName: 'Other Income',
        DatabaseConstants.colIconName: 'attach_money',
        DatabaseConstants.colColorHex: '#8BC34A',
        DatabaseConstants.colCategoryType: 'income',
        DatabaseConstants.colIsDefault: 1,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      },
    ];

    for (final Map<String, dynamic> cat in defaultCategories) {
      batch.insert(
        DatabaseConstants.tableCategories,
        cat,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  /// Closes the active database connection.
  Future<void> close() async {
    _initFuture = null;
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  /// Deletes the database file (useful for testing or full app reset).
  Future<void> deleteDatabaseFile() async {
    await close();
    final String path;
    if (databasePathOverride != null) {
      path = databasePathOverride!;
    } else {
      final String dbPath = await getDatabasesPath();
      path = p.join(dbPath, DatabaseConstants.databaseName);
    }
    final DatabaseFactory factory = databaseFactoryOverride ?? databaseFactory;
    await factory.deleteDatabase(path);
  }
}
