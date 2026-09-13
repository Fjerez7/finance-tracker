import '../domain/entities/cloud_backup_info.dart';

/// Abstract service contract for cloud database backup providers.
abstract class CloudBackupService {
  /// Uploads a snapshot to the designated cloud target.
  Future<List<CloudBackupInfo>> uploadBackup({
    required String backupJson,
    required String filename,
    required String checksum,
    CloudBackupDestination destination = CloudBackupDestination.all,
    String? userId,
  });

  /// Lists available cloud backups across configured providers.
  Future<List<CloudBackupInfo>> listBackups({
    CloudBackupDestination destination = CloudBackupDestination.all,
    String? userId,
  });

  /// Downloads raw JSON content for restoration from a specific cloud target.
  Future<String> downloadBackup({
    required String backupId,
    required CloudBackupDestination destination,
    String? userId,
  });

  /// Deletes a specific backup from its storage destination.
  Future<void> deleteBackup({
    required String backupId,
    required CloudBackupDestination destination,
    String? userId,
  });
}
