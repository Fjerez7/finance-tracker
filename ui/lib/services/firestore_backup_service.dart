import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/cloud_backup_info.dart';

/// Cloud backup service storing snapshots in Firebase Firestore.
class FirestoreBackupService {
  final FirebaseFirestore? _customFirestore;

  FirestoreBackupService({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  static String sanitizeUserId(String? userId) {
    if (userId == null || userId.trim().isEmpty) {
      return 'anonymous_user';
    }
    return userId.trim().replaceAll('/', '_');
  }

  CollectionReference<Map<String, dynamic>> _backupsCollection(String userId) {
    final sanitized = sanitizeUserId(userId);
    return _firestore.collection('users').doc(sanitized).collection('backups');
  }

  /// Uploads a backup snapshot to Firestore.
  Future<CloudBackupInfo> uploadBackup({
    required String backupJson,
    required String filename,
    required String checksum,
    String userId = 'anonymous_user',
  }) async {
    final docRef = _backupsCollection(userId).doc();
    final now = DateTime.now().toUtc();
    final sizeBytes = utf8.encode(backupJson).length;

    await docRef.set({
      'id': docRef.id,
      'name': filename,
      'version': 1,
      'checksum': checksum,
      'sizeBytes': sizeBytes,
      'createdAt': FieldValue.serverTimestamp(),
      'backupJson': backupJson,
    });

    return CloudBackupInfo(
      id: docRef.id,
      name: filename,
      destination: CloudBackupDestination.firestore,
      modifiedTime: now,
      sizeBytes: sizeBytes,
      checksum: checksum,
    );
  }

  /// Lists all available backups stored in Firestore for a user.
  Future<List<CloudBackupInfo>> listBackups({
    String userId = 'anonymous_user',
  }) async {
    final querySnapshot = await _backupsCollection(userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['createdAt'] as Timestamp?;
      final modifiedTime = timestamp?.toDate() ?? DateTime.now();

      return CloudBackupInfo(
        id: doc.id,
        name: data['name'] as String? ?? 'Firestore Backup',
        destination: CloudBackupDestination.firestore,
        modifiedTime: modifiedTime,
        sizeBytes: data['sizeBytes'] as int? ?? 0,
        checksum: data['checksum'] as String? ?? '',
        version: data['version'] as int? ?? 1,
      );
    }).toList();
  }

  /// Downloads raw JSON content for a specific backup ID from Firestore.
  Future<String> downloadBackup({
    required String backupId,
    String userId = 'anonymous_user',
  }) async {
    final docSnapshot =
        await _backupsCollection(userId).doc(backupId).get();

    if (!docSnapshot.exists) {
      throw StateError('Firestore backup $backupId does not exist.');
    }

    final data = docSnapshot.data();
    final backupJson = data?['backupJson'] as String?;
    if (backupJson == null || backupJson.isEmpty) {
      throw StateError('Firestore backup $backupId contains empty payload.');
    }

    return backupJson;
  }

  /// Deletes a backup document from Firestore.
  Future<void> deleteBackup({
    required String backupId,
    String userId = 'anonymous_user',
  }) async {
    await _backupsCollection(userId).doc(backupId).delete();
  }
}
