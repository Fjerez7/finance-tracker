---
id: spec-00001-estructura-de-carpetas-y-convenciones-flutter
type: spec
code: "00001"
slug: estructura-de-carpetas-y-convenciones-flutter
title: Flutter Project Folder Structure and Coding Conventions
description: Defines the canonical directory layout, Clean Architecture layer boundaries, component separation rules, and coding conventions for the Finance Tracker Flutter application.
category: interface
created: 2026-08-30
updated: 2026-08-30
authors: []
tags:
  - flutter
  - clean-architecture
  - conventions
  - folder-structure
  - mobile
related:
  - rfc-00001-arquitectura-base-de-finance-tracker
supersedes: []
superseded_by: null
aliases:
  - "SPEC 00001: Flutter Project Folder Structure and Coding Conventions"
---

# SPEC 00001: Flutter Project Folder Structure and Coding Conventions

## 1. Purpose

This specification defines the formal directory structure, architectural layer boundaries, component categorization rules (specifically distinguishing `screens` from `widgets`), and Dart/Flutter coding standards for the Finance Tracker application. It translates the architectural requirements established in `rfc-00001-arquitectura-base-de-finance-tracker` into actionable, deterministic rules for development, testing, and automated governance.

---

## 2. Definition

### 2.1. Project Root Directory Layout

The Flutter client application resides under the `ui/` directory of the repository. All source code follows a Clean Architecture layered hierarchy located under `ui/lib/`:

```
ui/
├── android/                        # Platform-specific Android configuration
├── ios/                            # Platform-specific iOS configuration
├── assets/                         # Static assets (images, icons, fonts)
│   ├── icons/
│   └── images/
├── test/                           # Automated test suites mirroring lib/
│   ├── unit/
│   │   ├── domain/
│   │   └── data/
│   ├── widget/
│   │   └── presentation/
│   └── mocks/
└── lib/                            # Application source root
    ├── main.dart                   # Application entrypoint & dependency bootstrap
    ├── core/                       # Shared foundational utilities, constants, & themes
    │   ├── constants/              # App-wide constants (routes, storage keys, colors)
    │   ├── errors/                 # Exceptions and failure definitions
    │   ├── theme/                  # Material 3 theme configurations (light/dark)
    │   └── utils/                  # Pure utility helpers (formatters, date parsers)
    ├── domain/                     # Pure business entities & abstract contracts
    │   ├── entities/               # Immutable business models
    │   └── repositories/           # Abstract repository interface contracts
    ├── data/                       # Concrete data sources & repository implementations
    │   ├── datasources/            # Low-level SQLite database & Google Drive API client
    │   │   ├── local/              # SQLite database helper, tables, & migrations
    │   │   └── remote/             # Google Drive backup client (OAuth2 & AppData)
    │   ├── models/                 # Data transfer objects (DTOs) & DB row mappers
    │   └── repositories/           # Concrete implementations of domain repositories
    ├── providers/                  # Application state management (ChangeNotifier)
    │   ├── account_provider.dart
    │   ├── budget_provider.dart
    │   ├── transaction_provider.dart
    │   └── backup_provider.dart
    └── presentation/               # Declarative UI layer
        ├── screens/                # Full-page navigable route views
        │   ├── dashboard/
        │   ├── transactions/
        │   ├── budgets/
        │   ├── accounts/
        │   └── settings/
        └── widgets/                # Reusable, modular UI components
            ├── common/             # Universal components (buttons, input fields, dialogs)
            ├── charts/             # Expense and budget visual charts (fl_chart wrappers)
            └── cards/              # Metric summary cards & balance overview tiles
```

---

### 2.2. Architectural Layers & Responsibilities

#### 1. Domain Layer (`lib/domain/`)
- **Isolation:** Pure Dart package without dependencies on Flutter UI, SQLite libraries, or platform-specific plugins.
- **Entities (`lib/domain/entities/`):** Immutable data structures representing core business concepts (`Account`, `Transaction`, `Category`, `Budget`, `BackupSnapshot`). Entities use integer minor units (cents) for all financial currency amounts.
- **Repository Interfaces (`lib/domain/repositories/`):** Abstract contracts defining business operations (e.g., `TransactionRepository`, `AccountRepository`, `BackupRepository`).

#### 2. Data Layer (`lib/data/`)
- **Responsibilities:** Implements domain repository interfaces and orchestrates local persistence and cloud synchronization.
- **Datasources (`lib/data/datasources/`):**
  - `local/`: SQLite table definitions, database connection lifecycle (`DatabaseHelper`), query executions, and schema migrations.
  - `remote/`: Google Drive OAuth2 sign-in integration and AppData folder file synchronization.
- **Models (`lib/data/models/`):** DTOs that handle serialization to and from SQLite rows (`Map<String, dynamic>`) and JSON backup archives, with conversion methods (`toDomain()`, `fromDomain()`).
- **Repositories (`lib/data/repositories/`):** Concrete implementations of domain repository interfaces (e.g., `SqliteTransactionRepository`).

#### 3. Application / State Layer (`lib/providers/`)
- **Responsibilities:** Manages screen-agnostic application state and coordinates domain operations via `ChangeNotifier`.
- **Behavior:**
  - Injects domain repository interfaces via constructor dependency injection.
  - Exposes reactive getters (`List<Transaction>`, `int totalBalanceCents`, `bool isLoading`).
  - Handles business workflows (e.g., creating a transaction, recomputing monthly category summaries, triggering Google Drive cloud backup).
  - Emits updates using `notifyListeners()`.

#### 4. Presentation Layer (`lib/presentation/`)
- **Rule of Separation:** Strict separation between **Screens** and **Widgets**.

##### A. Screens (`lib/presentation/screens/`)
- **Definition:** Top-level navigable route destinations representing full screen views (e.g., `DashboardScreen`, `TransactionListScreen`, `AddTransactionScreen`, `SettingsScreen`).
- **Characteristics:**
  - Own a `Scaffold`, `AppBar`, or navigation shell.
  - Connect to providers via `Consumer` or `context.watch<T>()` to supply data to child widgets.
  - Dispatch user intents to providers (e.g., `context.read<TransactionProvider>().deleteTransaction(id)`).
  - Do **not** contain low-level reusable styling or inline repetitive layout blocks.

##### B. Widgets (`lib/presentation/widgets/`)
- **Definition:** Modular, self-contained, and reusable visual building blocks.
- **Categorization:**
  - `widgets/common/`: App-wide primitive components (e.g., `CurrencyInputField`, `PrimaryButton`, `ConfirmDialog`, `CategoryIconAvatar`).
  - `widgets/cards/`: Domain-oriented visual widgets (e.g., `AccountBalanceCard`, `TransactionListTile`, `BudgetProgressCard`).
  - `widgets/charts/`: Visualization wrappers (e.g., `MonthlyExpensePieChart`, `CashFlowBarChart`).
- **Characteristics:**
  - Receive data and callbacks via explicit constructor parameters where possible to maximize testability and reusability.
  - Do not directly instantiate or manipulate database queries or network requests.

#### 5. Core Layer (`lib/core/`)
- **Responsibilities:** Shared utilities that do not belong to a specific business feature.
- **Components:**
  - `constants/`: Route names, database table/column string constants, format constants.
  - `errors/`: Custom failure hierarchy (`Failure`, `DatabaseFailure`, `BackupFailure`).
  - `theme/`: Color palettes, typography, Material 3 `ThemeData` definitions.
  - `utils/`: Money formatter (cents to localized `$XX.XX`), date/time parsers, and validation helpers.

---

### 2.3. Coding & Naming Conventions

| Artifact Type | Naming Convention | Example |
| :--- | :--- | :--- |
| **Directory Names** | `snake_case` | `domain/entities/`, `presentation/widgets/cards/` |
| **File Names** | `snake_case.dart` | `transaction_provider.dart`, `sqlite_database_helper.dart` |
| **Classes / Types / Enums** | `UpperCamelCase` | `TransactionEntity`, `AccountProvider`, `TransactionType` |
| **Variables / Properties** | `lowerCamelCase` | `amountCents`, `createdAt`, `isBackupRunning` |
| **Functions / Methods** | `lowerCamelCase` | `calculateTotalBalance()`, `loadTransactions()` |
| **Constants (File / Class)** | `lowerCamelCase` (Dart standard) | `defaultPadding`, `databaseVersion`, `appDataScope` |
| **Screens** | Suffix with `Screen` | `DashboardScreen`, `AddTransactionScreen` |
| **Widgets** | Suffix with descriptive type | `TransactionListTile`, `CurrencyInputField` |
| **Providers** | Suffix with `Provider` | `TransactionProvider`, `BudgetProvider` |
| **Repositories (Interface)** | Suffix with `Repository` | `TransactionRepository`, `BackupRepository` |
| **Repositories (Impl)** | Prefix with technology/storage | `SqliteTransactionRepository`, `GoogleDriveBackupRepository` |

---

## 3. Invariants

1. **Strict Dependency Flow:**
   - Dependencies must strictly point inwards:
     $$\text{Presentation / Providers} \longrightarrow \text{Domain} \longleftarrow \text{Data}$$
   - The `domain/` layer must NEVER import packages from `data/`, `providers/`, or `presentation/`.
   - The `domain/` layer must NEVER import `flutter/material.dart` or any UI framework library.

2. **Money Precision Invariant:**
   - Monetary values must ALWAYS be represented as integer minor units (`int amountCents`) across all Domain Entities, SQLite schemas, and Provider calculations.
   - IEEE-754 floating-point numbers (`double`, `float`) are STRICTLY FORBIDDEN for storing, transferring, or calculating currency values. Conversions to fractional decimal representations are permitted exclusively at the Presentation formatting boundary (e.g., rendering `"$12.50"` for display).

3. **No Direct Data/Service Access from UI:**
   - Widgets and Screens MUST NOT directly instantiate SQLite database instances, execute SQL queries, or invoke Google Drive API endpoints. All interactions must pass through the respective `Provider` and abstract `Repository` interface.

4. **Immutable Domain Entities:**
   - All classes in `domain/entities/` must be immutable with `final` fields and provide `copyWith()` methods for creating modified instances.

5. **Identifier Uniformity:**
   - All persistent entities must utilize UUIDv4 strings for primary keys (`id`), formatted as canonical lowercase 36-character hyphenated UUIDs.

6. **Deterministic Date Storage:**
   - All timestamps (`createdAt`, `updatedAt`, `deletedAt`) must be stored and transferred in UTC ISO-8601 string format (`YYYY-MM-DDTHH:MM:SS.mmmZ`).

---

## 4. Examples

### 4.1. Concrete Entity Specification (`lib/domain/entities/transaction.dart`)

```dart
enum TransactionType { income, expense, transfer }

class Transaction {
  final String id;
  final String accountId;
  final String? categoryId;
  final int amountCents; // e.g., $10.50 is stored as 1050
  final TransactionType type;
  final String description;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.accountId,
    this.categoryId,
    required this.amountCents,
    required this.type,
    required this.description,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Transaction copyWith({
    String? id,
    String? accountId,
    String? categoryId,
    int? amountCents,
    TransactionType? type,
    String? description,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amountCents: amountCents ?? this.amountCents,
      type: type ?? this.type,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

### 4.2. Repository Interface Contract (`lib/domain/repositories/transaction_repository.dart`)

```dart
abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();
  Future<Transaction?> getTransactionById(String id);
  Future<List<Transaction>> getTransactionsByAccount(String accountId);
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
}
```

### 4.3. Provider Implementation (`lib/providers/transaction_provider.dart`)

```dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  TransactionProvider({required TransactionRepository repository})
      : _repository = repository;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalIncomeCents => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amountCents);

  int get totalExpenseCents => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amountCents);

  int get netBalanceCents => totalIncomeCents - totalExpenseCents;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _repository.getAllTransactions();
    } catch (e) {
      _errorMessage = 'Failed to load transactions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTransaction(Transaction transaction) async {
    try {
      await _repository.addTransaction(transaction);
      _transactions.insert(0, transaction);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save transaction: $e';
      notifyListeners();
    }
  }
}
```

### 4.4. Screen vs Widget Implementation

#### Screen (`lib/presentation/screens/dashboard/dashboard_screen.dart`):
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../widgets/cards/balance_summary_card.dart';
import '../../widgets/cards/transaction_list_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Finance Tracker')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.loadTransactions(),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  BalanceSummaryCard(
                    netBalanceCents: provider.netBalanceCents,
                    incomeCents: provider.totalIncomeCents,
                    expenseCents: provider.totalExpenseCents,
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Recent Transactions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  ...provider.transactions.map((tx) => TransactionListTile(transaction: tx)),
                ],
              ),
            ),
    );
  }
}
```

#### Reusable Widget (`lib/presentation/widgets/cards/transaction_list_tile.dart`):
```dart
import 'package:flutter/material.dart';
import '../../../domain/entities/transaction.dart';
import '../../../core/utils/currency_formatter.dart';

class TransactionListTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionListTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.redAccent;
    final prefix = isIncome ? '+' : '-';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
        ),
      ),
      title: Text(transaction.description),
      subtitle: Text(transaction.transactionDate.toLocal().toString().split(' ')[0]),
      trailing: Text(
        '$prefix${CurrencyFormatter.formatCents(transaction.amountCents)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
```

---

## 5. Resolved Decisions

- **Single Currency in v1:** Conforming to `rfc-00001`, the application operates with a single user-configured base currency (e.g., USD, COP, EUR) in v1. Multi-currency exchange rate conversions are strictly deferred to v2.
- **State Restoration:** Route and form state restoration will use standard Provider observables in v1; OS-level process death state serialization is deferred.
