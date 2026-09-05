# Finance Tracker UI

The Flutter mobile client for **Finance Tracker**, an offline-first personal finance management application built with Clean Architecture, SQLite local persistence, and optional Google Drive synchronization.

## Architecture

The project strictly follows Clean Architecture layer boundaries as specified in `spec-00001`:

```
lib/
├── main.dart                   # Application entrypoint & dependency bootstrap
├── core/                       # Shared constants, errors, themes, and utilities
│   ├── constants/
│   ├── errors/
│   ├── theme/
│   └── utils/
├── domain/                     # Pure business entities & abstract contracts
│   ├── entities/
│   └── repositories/
├── data/                       # Concrete datasources & repository implementations
│   ├── datasources/
│   │   ├── local/              # SQLite database helpers & tables
│   │   └── remote/             # Cloud sync & OAuth clients
│   ├── models/                 # Data transfer objects & DB row mappers
│   └── repositories/           # Concrete repository implementations
├── providers/                  # Application state management (Provider / ChangeNotifier)
└── presentation/               # Declarative UI layer
    ├── screens/                # Full-page navigable route views
    │   ├── accounts/
    │   ├── budgets/
    │   ├── dashboard/
    │   ├── settings/
    │   └── transactions/
    └── widgets/                # Reusable UI components
        ├── cards/
        ├── charts/
        └── common/
```

## Key Design Invariants

- **Integer Cent Precision:** All monetary amounts, balances, and budget limits are stored and computed strictly as 64-bit integer cents (`int`), preventing floating-point rounding errors.
- **Local-First Persistence:** Core application data is persisted locally in SQLite (`sqflite`) with foreign key enforcement and default seed categories.

## Key Dependencies

- **State Management:** `provider`
- **Local Database:** `sqflite`, `sqflite_common_ffi`, `path`
- **Charts & Visualization:** `fl_chart`
- **Formatting & Localization:** `intl`
- **Cloud Backup:** `google_sign_in`, `googleapis`

## Development & Quality Assurance

### Run static analysis
```bash
flutter analyze
```

### Run automated tests
```bash
flutter test
```

### Run the application
```bash
flutter run
```
