import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import '../data/datasources/local/database_helper.dart';
import '../domain/entities/account.dart';
import '../domain/entities/category.dart';
import '../domain/entities/transaction.dart';
import '../services/backup_restore_service.dart';
import '../services/csv_export_service.dart';
import '../services/google_drive_service.dart';

/// Reactive provider managing Google Drive cloud backups, local exports, and database restorations.
class BackupProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  final GoogleDriveService _driveService;

  bool _isLoading = false;
  bool _isSyncing = false;
  String? _errorMessage;
  String? _successMessage;
  List<DriveBackupInfo> _cloudBackups = [];

  BackupProvider({
    DatabaseHelper? dbHelper,
    GoogleDriveService? driveService,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _driveService = driveService ?? GoogleDriveService();

  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<DriveBackupInfo> get cloudBackups => List.unmodifiable(_cloudBackups);
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

  /// Fetches the list of backup files stored in Google Drive appDataFolder.
  Future<void> fetchCloudBackups() async {
    if (!isSignedIn) return;
    _setSyncing(true);
    try {
      _cloudBackups = await _driveService.listBackups();
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

  /// Exports and uploads a new database backup snapshot to Google Drive appDataFolder.
  Future<bool> createCloudBackup() async {
    if (!isSignedIn) {
      _errorMessage = 'Please sign in to Google Drive first.';
      notifyListeners();
      return false;
    }

    _setSyncing(true);
    _clearMessages();
    try {
      final snapshot = await createLocalSnapshot();
      final String snapshotJson = jsonEncode(snapshot);
      final String timestamp =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String filename = 'finance_tracker_backup_$timestamp.json';

      await _driveService.uploadBackup(
        backupJson: snapshotJson,
        filename: filename,
      );

      _successMessage = 'Backup successfully saved to Google Drive';
      await fetchCloudBackups();
      _setSyncing(false);
      return true;
    } catch (e) {
      _errorMessage = 'Backup upload failed: ${e.toString()}';
      _setSyncing(false);
      return false;
    }
  }

  /// Downloads and restores database from a selected remote Google Drive backup.
  Future<bool> restoreCloudBackup(String fileId) async {
    _setSyncing(true);
    _clearMessages();
    try {
      final String jsonContent = await _driveService.downloadBackup(fileId);
      final Map<String, dynamic> snapshot =
          jsonDecode(jsonContent) as Map<String, dynamic>;

      final db = await _dbHelper.database;
      await BackupRestoreService.restoreFromSnapshot(db, snapshot);

      _successMessage = 'Database successfully restored from cloud backup';
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

  /// Exports transactions to an RFC 4180 CSV string.
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
