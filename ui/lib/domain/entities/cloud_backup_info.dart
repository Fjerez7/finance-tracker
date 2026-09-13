/// Supported cloud storage targets for database backups.
enum CloudBackupDestination {
  firestore,
  googleDrive,
  all,
}

/// DTO representing a remote cloud backup snapshot.
class CloudBackupInfo {
  final String id;
  final String name;
  final CloudBackupDestination destination;
  final DateTime modifiedTime;
  final int sizeBytes;
  final String checksum;
  final int version;

  const CloudBackupInfo({
    required this.id,
    required this.name,
    required this.destination,
    required this.modifiedTime,
    required this.sizeBytes,
    required this.checksum,
    this.version = 1,
  });

  /// Formatted display label for the storage destination.
  String get destinationLabel {
    switch (destination) {
      case CloudBackupDestination.firestore:
        return 'Firebase Firestore';
      case CloudBackupDestination.googleDrive:
        return 'Google Drive';
      case CloudBackupDestination.all:
        return 'Dual Cloud (Firestore + Drive)';
    }
  }
}
