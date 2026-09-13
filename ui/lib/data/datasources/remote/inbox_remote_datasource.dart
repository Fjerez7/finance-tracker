import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../models/inbox_transaction_model.dart';

/// Contract for fetching and updating staged inbox transactions in Cloud Firestore.
abstract class InboxRemoteDataSource {
  /// Retrieves all pending transactions for a given user.
  Future<List<InboxTransactionModel>> getPendingTransactions({String userId = 'user_default'});

  /// Acknowledges ingestion by marking a staged transaction as SYNCED.
  Future<void> markAsSynced(String transactionId, {String userId = 'user_default'});

  /// Marks a staged transaction as DISCARDED.
  Future<void> markAsDiscarded(String transactionId, {String userId = 'user_default'});
}

/// Firestore implementation of [InboxRemoteDataSource].
class InboxRemoteDataSourceImpl implements InboxRemoteDataSource {
  final FirebaseFirestore? _customFirestore;

  InboxRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    if (Firebase.apps.isNotEmpty) {
      return FirebaseFirestore.instance;
    }
    return null;
  }

  CollectionReference<Map<String, dynamic>>? _userInbox(String userId) {
    final firestore = _firestore;
    if (firestore == null) return null;
    return firestore.collection('users').doc(userId).collection('inbox_transactions');
  }

  @override
  Future<List<InboxTransactionModel>> getPendingTransactions({String userId = 'user_default'}) async {
    final inbox = _userInbox(userId);
    if (inbox == null) return [];

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await inbox
          .where('status', isEqualTo: 'PENDING')
          .get();

      return snapshot.docs
          .map((doc) => InboxTransactionModel.fromFirestore(doc))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> markAsSynced(String transactionId, {String userId = 'user_default'}) async {
    final inbox = _userInbox(userId);
    if (inbox == null) return;

    try {
      await inbox.doc(transactionId).update({
        'status': 'SYNCED',
        'synced_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {}
  }

  @override
  Future<void> markAsDiscarded(String transactionId, {String userId = 'user_default'}) async {
    final inbox = _userInbox(userId);
    if (inbox == null) return;

    try {
      await inbox.doc(transactionId).update({
        'status': 'DISCARDED',
        'synced_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {}
  }
}
