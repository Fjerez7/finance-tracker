import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import '../data/datasources/local/database_helper.dart';
import '../domain/entities/account.dart';
import '../domain/entities/category.dart';
import '../domain/entities/cloud_backup_info.dart';
import '../domain/entities/transaction.dart';
import '../services/backup_restore_service.dart';
import '../services/cloud_backup_service.dart';
import '../services/csv_export_service.dart';
import '../services/file_export_service.dart';
import '../services/google_drive_service.dart';
import '../services/hybrid_cloud_backup_service.dart';

/// Reactive provider managing hybrid cloud backups (Firestore + Drive), local exports, and database restorations.
class BackupProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  final CloudBackupService _cloudBackupService;
  final GoogleDriveService _driveService;
  final FileExportService _fileExportService;

  bool _isLoading = false;
  bool _isSyncing = false;
  String? _errorMessage;
  String? _successMessage;
  List<CloudBackupInfo> _cloudBackups = [];

  BackupProvider({
    DatabaseHelper? dbHelper,
    CloudBackupService? cloudBackupService,
    GoogleDriveService? driveService,
    FileExportService? fileExportService,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _driveService = driveService ?? GoogleDriveService(),
        _fileExportService = fileExportService ?? FileExportService(),
        _cloudBackupService = cloudBackupService ??
            HybridCloudBackupService(
              driveService: driveService,
            );

  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<CloudBackupInfo> get cloudBackups => List.unmodifiable(_cloudBackups);
  GoogleSignInAccount? get currentUser => _driveService.currentUser;
  bool get isSignedIn => _driveService.currentUser != null;

  void clearStatus() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Attempts silent Google Sign-In on app startup.
  Future<void> checkExistingAuth() async {
    try {
      await _driveService.signInSilently();
      if (isSignedIn) {
        await fetchCloudBackups();
      }
    } catch (_) {
      // Non-blocking silent failure
    }
  }

  /// Initiates interactive Google Sign-In.
  Future<bool> signIn() async {
    _setLoading(true);
    _clearMessages();
    try {
      final account = await _driveService.signIn();
      if (account != null) {
        _successMessage = 'Signed in as ${account.email}';
        await fetchCloudBackups();
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Sign in failed: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Signs out from Google session and clears cached cloud backups list.
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _driveService.signOut();
      _cloudBackups = [];
      _successMessage = 'Signed out from Google Drive';
    } catch (e) {
      _errorMessage = 'Sign out failed: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Fetches the list of backup files from configured cloud providers.
  Future<void> fetchCloudBackups({
    CloudBackupDestination destination = CloudBackupDestination.all,
    String? userId,
  }) async {
    _setSyncing(true);
    try {
      _cloudBackups = await _cloudBackupService.listBackups(
        destination: destination,
        userId: userId,
      );
    } catch (e) {
      _errorMessage = 'Failed to retrieve backups: ${e.toString()}';
    } finally {
      _setSyncing(false);
    }
  }

  /// Creates a local JSON snapshot with SHA-256 integrity hash.
  Future<Map<String, dynamic>> createLocalSnapshot() async {
    final db = await _dbHelper.database;
    return await BackupRestoreService.createBackupSnapshot(db);
  }

  /// Exports and uploads database backup snapshot to cloud destinations (Firestore + Drive).
  Future<bool> createCloudBackup({
    CloudBackupDestination destination = CloudBackupDestination.all,
    String? userId,
  }) async {
    _setSyncing(true);
    _clearMessages();
    try {
      final snapshot = await createLocalSnapshot();
      final String snapshotJson = jsonEncode(snapshot);
      final String checksum = snapshot['checksum'] as String? ?? '';
      final String timestamp =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String filename = 'finance_tracker_backup_$timestamp.json';

      final results = await _cloudBackupService.uploadBackup(
        backupJson: snapshotJson,
        filename: filename,
        checksum: checksum,
        destination: destination,
        userId: userId,
      );

      if (results.isEmpty) {
        throw StateError('No cloud provider completed backup successfully.');
      }

      final destinations = results.map((r) => r.destinationLabel).join(' & ');
      _successMessage = 'Backup saved to $destinations';
      await fetchCloudBackups(userId: userId);
      _setSyncing(false);
      return true;
    } catch (e) {
      _errorMessage = 'Backup upload failed: ${e.toString()}';
      _setSyncing(false);
      return false;
    }
  }

  /// Downloads and restores database from a selected remote cloud backup.
  Future<bool> restoreCloudBackup(
    CloudBackupInfo backup, {
    String? userId,
  }) async {
    _setSyncing(true);
    _clearMessages();
    try {
      final String jsonContent = await _cloudBackupService.downloadBackup(
        backupId: backup.id,
        destination: backup.destination,
        userId: userId,
      );
      final Map<String, dynamic> snapshot =
          jsonDecode(jsonContent) as Map<String, dynamic>;

      final db = await _dbHelper.database;
      await BackupRestoreService.restoreFromSnapshot(db, snapshot);

      _successMessage = 'Database restored successfully from ${backup.destinationLabel}';
      _setSyncing(false);
      return true;
    } catch (e) {
      _errorMessage = 'Restoration failed: ${e.toString()}';
      _setSyncing(false);
      return false;
    }
  }

  /// Restores database state from a local JSON snapshot.
  Future<bool> restoreFromLocalSnapshot(Map<String, dynamic> snapshot) async {
    _setLoading(true);
    _clearMessages();
    try {
      final db = await _dbHelper.database;
      await BackupRestoreService.restoreFromSnapshot(db, snapshot);
      _successMessage = 'Database restored successfully';
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Restoration failed: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Exports and shares CSV ledger file via native OS share sheet.
  Future<void> shareTransactionsCsv({
    required List<Transaction> transactions,
    required List<Account> accounts,
    required List<Category> categories,
  }) async {
    final csv = CsvExportService.exportTransactionsToCsv(
      transactions: transactions,
      accounts: accounts,
      categories: categories,
    );
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final filename = 'finance_tracker_transactions_$dateStr.csv';

    await _fileExportService.shareCsv(
      csvContent: csv,
      filename: filename,
      subject: 'Finance Tracker Transactions ($dateStr)',
    );
  }

  /// Exports and shares full database JSON snapshot via native OS share sheet.
  Future<void> shareDatabaseJson() async {
    final snapshot = await createLocalSnapshot();
    final jsonStr = jsonEncode(snapshot);
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename = 'finance_tracker_backup_$dateStr.json';

    await _fileExportService.shareJson(
      jsonContent: jsonStr,
      filename: filename,
      subject: 'Finance Tracker Database Snapshot ($dateStr)',
    );
  }

  /// Prompts the user to pick a local .json file and restores the database from it.
  Future<bool> pickAndRestoreLocalJson() async {
    _setLoading(true);
    _clearMessages();
    try {
      final jsonContent = await _fileExportService.pickLocalJsonBackup();
      if (jsonContent == null || jsonContent.isEmpty) {
        _setLoading(false);
        return false;
      }

      final Map<String, dynamic> snapshot =
          jsonDecode(jsonContent) as Map<String, dynamic>;

      final db = await _dbHelper.database;
      await BackupRestoreService.restoreFromSnapshot(db, snapshot);
      _successMessage = 'Database restored successfully from local file';
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Local restore failed: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  /// Exports transactions to an RFC 4180 CSV string (for in-memory / testing preview).
  String exportTransactionsCsv({
    required List<Transaction> transactions,
    required List<Account> accounts,
    required List<Category> categories,
  }) {
    return CsvExportService.exportTransactionsToCsv(
      transactions: transactions,
      accounts: accounts,
      categories: categories,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSyncing(bool value) {
    _isSyncing = value;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }
}
