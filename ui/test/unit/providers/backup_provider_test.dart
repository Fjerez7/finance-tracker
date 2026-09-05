import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:finance_tracker/core/constants/database_constants.dart';
import 'package:finance_tracker/data/datasources/local/database_helper.dart';
import 'package:finance_tracker/domain/entities/account.dart';
import 'package:finance_tracker/domain/entities/category.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/providers/backup_provider.dart';
import 'package:finance_tracker/services/google_drive_service.dart';

class FakeGoogleDriveService extends GoogleDriveService {
  GoogleSignInAccount? fakeUser;
  final List<DriveBackupInfo> backups = [];
  String? uploadedContent;

  @override
  GoogleSignInAccount? get currentUser => fakeUser;

  @override
  Future<GoogleSignInAccount?> signIn() async {
    return fakeUser;
  }

  @override
  Future<void> signOut() async {
    fakeUser = null;
    backups.clear();
  }

  @override
  Future<drive.File> uploadBackup({
    required String backupJson,
    required String filename,
  }) async {
    uploadedContent = backupJson;
    final info = DriveBackupInfo(
      id: 'file-123',
      name: filename,
      modifiedTime: DateTime.now(),
      sizeBytes: backupJson.length,
    );
    backups.add(info);
    return drive.File()..id = 'file-123'..name = filename;
  }

  @override
  Future<List<DriveBackupInfo>> listBackups() async {
    return List.from(backups);
  }

  @override
  Future<String> downloadBackup(String fileId) async {
    return uploadedContent ?? '{}';
  }
}

void main() {
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;
  late Database db;
  late FakeGoogleDriveService fakeDriveService;
  late BackupProvider provider;

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    dbHelper.databaseFactoryOverride = databaseFactoryFfi;
    dbHelper.databasePathOverride = inMemoryDatabasePath;

    await dbHelper.close();
    db = await dbHelper.database;

    fakeDriveService = FakeGoogleDriveService();
    provider = BackupProvider(
      dbHelper: dbHelper,
      driveService: fakeDriveService,
    );
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('BackupProvider Unit Tests', () {
    test('createLocalSnapshot and restoreFromLocalSnapshot roundtrip succeeds', () async {
      final now = DateTime.now().toUtc().toIso8601String();

      await db.insert(DatabaseConstants.tableAccounts, {
        DatabaseConstants.colId: 'acc-snap-1',
        DatabaseConstants.colName: 'Crypto Wallet',
        DatabaseConstants.colAccountType: 'digital_wallet',
        DatabaseConstants.colBalanceCents: 250000,
        DatabaseConstants.colCreditLimitCents: 0,
        DatabaseConstants.colCurrency: 'USD',
        DatabaseConstants.colColorHex: '#FF9800',
        DatabaseConstants.colIconName: 'account_balance_wallet',
        DatabaseConstants.colIsArchived: 0,
        DatabaseConstants.colCreatedAt: now,
        DatabaseConstants.colUpdatedAt: now,
      });

      final snapshot = await provider.createLocalSnapshot();
      expect(snapshot['version'], equals(1));
      expect(snapshot['checksum'], isNotEmpty);

      // Clear accounts
      await db.delete(DatabaseConstants.tableAccounts);
      final emptyAccounts = await db.query(DatabaseConstants.tableAccounts);
      expect(emptyAccounts, isEmpty);

      // Restore snapshot
      final success = await provider.restoreFromLocalSnapshot(snapshot);
      expect(success, isTrue);
      expect(provider.successMessage, contains('Database restored successfully'));

      final restoredAccounts = await db.query(DatabaseConstants.tableAccounts);
      expect(restoredAccounts.length, equals(1));
      expect(restoredAccounts.first['name'], equals('Crypto Wallet'));
    });

    test('exportTransactionsCsv returns formatted RFC 4180 CSV string', () {
      final now = DateTime(2026, 9, 5);
      final account = Account(
        id: 'a1',
        name: 'Bank',
        type: AccountType.bank,
        currency: 'USD',
        balanceCents: 10000,
        colorHex: '#000000',
        iconName: 'bank',
        createdAt: now,
        updatedAt: now,
      );
      final category = Category(
        id: 'c1',
        name: 'Dining',
        iconName: 'food',
        colorHex: '#000000',
        type: CategoryType.expense,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      );
      final tx = Transaction(
        id: 'tx1',
        accountId: 'a1',
        categoryId: 'c1',
        amountCents: 2000,
        type: TransactionType.expense,
        description: 'Lunch',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final csv = provider.exportTransactionsCsv(
        transactions: [tx],
        accounts: [account],
        categories: [category],
      );

      expect(csv, contains('ID,Date,Account,Category,Type,Amount_Formatted,Amount_Cents,Description'));
      expect(csv, contains('tx1,2026-09-05 00:00:00,Bank,Dining,expense,20.00,2000,Lunch'));
    });

    test('cloud backup creation fails if user is not signed in', () async {
      final success = await provider.createCloudBackup();
      expect(success, isFalse);
      expect(provider.errorMessage, contains('Please sign in to Google Drive first'));
    });
  });
}
