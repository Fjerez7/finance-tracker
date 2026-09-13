import 'dart:async';
import '../domain/entities/cloud_backup_info.dart';
import 'cloud_backup_service.dart';
import 'firestore_backup_service.dart';
import 'google_drive_service.dart';

/// Orchestrates multi-destination backups across Firebase Firestore and Google Drive.
class HybridCloudBackupService implements CloudBackupService {
  final FirestoreBackupService _firestoreService;
  final GoogleDriveService _driveService;

  HybridCloudBackupService({
    FirestoreBackupService? firestoreService,
    GoogleDriveService? driveService,
  })  : _firestoreService = firestoreService ?? FirestoreBackupService(),
        _driveService = driveService ?? GoogleDriveService();

  FirestoreBackupService get firestoreService => _firestoreService;
  GoogleDriveService get driveService => _driveService;

  @override
  Future<List<CloudBackupInfo>> uploadBackup({
    required String backupJson,
    required String filename,
    required String checksum,
    CloudBackupDestination destination = CloudBackupDestination.all,
    String? userId,
  }) async {
    final List<CloudBackupInfo> results = [];
    final List<String> errors = [];

    final bool targetFirestore = destination == CloudBackupDestination.all ||
        destination == CloudBackupDestination.firestore;
    final bool targetDrive = destination == CloudBackupDestination.all ||
        destination == CloudBackupDestination.googleDrive;

    final List<Future<void>> tasks = [];

    if (targetFirestore) {
      tasks.add(
        _firestoreService
            .uploadBackup(
              backupJson: backupJson,
              filename: filename,
              checksum: checksum,
              userId: userId ?? 'anonymous_user',
            )
            .then((info) => results.add(info))
            .catchError((e) {
              errors.add('Firestore: $e');
            }),
      );
    }

    if (targetDrive && _driveService.currentUser != null) {
      tasks.add(
        _driveService
            .uploadBackup(
              backupJson: backupJson,
              filename: filename,
            )
            .then((driveFile) {
              results.add(
                CloudBackupInfo(
                  id: driveFile.id ?? '',
                  name: driveFile.name ?? filename,
                  destination: CloudBackupDestination.googleDrive,
                  modifiedTime: driveFile.modifiedTime ?? DateTime.now(),
                  sizeBytes: driveFile.size != null
                      ? int.tryParse(driveFile.size!) ?? 0
                      : 0,
                  checksum: checksum,
                ),
              );
            })
            .catchError((e) {
              errors.add('Google Drive: $e');
            }),
      );
    }

    await Future.wait(tasks);

    if (results.isEmpty && errors.isNotEmpty) {
      throw StateError('Backup upload failed: ${errors.join(', ')}');
    }

    return results;
  }

  @override
  Future<List<CloudBackupInfo>> listBackups({
    CloudBackupDestination destination = CloudBackupDestination.all,
    String? userId,
  }) async {
    final List<CloudBackupInfo> combined = [];

    final bool queryFirestore = destination == CloudBackupDestination.all ||
        destination == CloudBackupDestination.firestore;
    final bool queryDrive = destination == CloudBackupDestination.all ||
        destination == CloudBackupDestination.googleDrive;

    final List<Future<void>> tasks = [];

    if (queryFirestore) {
      tasks.add(
        _firestoreService
            .listBackups(userId: userId ?? 'anonymous_user')
            .then((list) => combined.addAll(list))
            .catchError((_) {}),
      );
    }

    if (queryDrive && _driveService.currentUser != null) {
      tasks.add(
        _driveService
            .listBackups()
            .then((list) => combined.addAll(list))
            .catchError((_) {}),
      );
    }

    await Future.wait(tasks);

    // Sort descending by modifiedTime
    combined.sort((a, b) => b.modifiedTime.compareTo(a.modifiedTime));
    return combined;
  }

  @override
  Future<String> downloadBackup({
    required String backupId,
    required CloudBackupDestination destination,
    String? userId,
  }) async {
    switch (destination) {
      case CloudBackupDestination.firestore:
        return await _firestoreService.downloadBackup(
          backupId: backupId,
          userId: userId ?? 'anonymous_user',
        );
      case CloudBackupDestination.googleDrive:
      case CloudBackupDestination.all:
        return await _driveService.downloadBackup(backupId);
    }
  }

  @override
  Future<void> deleteBackup({
    required String backupId,
    required CloudBackupDestination destination,
    String? userId,
  }) async {
    switch (destination) {
      case CloudBackupDestination.firestore:
        await _firestoreService.deleteBackup(
          backupId: backupId,
          userId: userId ?? 'anonymous_user',
        );
        break;
      case CloudBackupDestination.googleDrive:
      case CloudBackupDestination.all:
        await _driveService.deleteBackup(backupId);
        break;
    }
  }
}
