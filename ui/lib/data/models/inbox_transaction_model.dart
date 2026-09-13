import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/inbox_transaction.dart';

/// Model representing a staged inbox transaction document from Firestore.
class InboxTransactionModel extends InboxTransaction {
  const InboxTransactionModel({
    required super.id,
    required super.bankName,
    required super.accountType,
    required super.accountMask,
    required super.merchant,
    required super.amountCents,
    required super.amount,
    required super.currency,
    required super.type,
    required super.categorySuggestion,
    required super.transactionDate,
    required super.referenceNumber,
    required super.status,
    required super.createdAt,
    super.syncedAt,
  });

  /// Deserializes a Firestore document snapshot.
  factory InboxTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = (doc.data() as Map<String, dynamic>?) ?? {};
    return InboxTransactionModel.fromMap(doc.id, data);
  }

  /// Deserializes a generic Map.
  factory InboxTransactionModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is Timestamp) return val.toDate();
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    int parseAmountCents(dynamic val, dynamic altAmount) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      if (val is double) return val.round();
      if (altAmount is num) return (altAmount * 100).round();
      return 0;
    }

    double parseAmount(dynamic val, int cents) {
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? (cents / 100.0);
      return cents / 100.0;
    }

    final int cents = parseAmountCents(map['amount_cents'], map['amount']);
    final double amt = parseAmount(map['amount'], cents);

    return InboxTransactionModel(
      id: map['id']?.toString() ?? id,
      bankName: map['bank_name']?.toString() ?? 'Unknown Bank',
      accountType: map['account_type']?.toString() ?? 'other',
      accountMask: map['account_mask']?.toString() ?? '',
      merchant: map['merchant']?.toString() ?? 'Unknown Merchant',
      amountCents: cents,
      amount: amt,
      currency: map['currency']?.toString() ?? 'USD',
      type: map['type']?.toString() ?? 'expense',
      categorySuggestion: map['category_suggestion']?.toString() ?? 'Other Expenses',
      transactionDate: parseDate(map['transaction_date']),
      referenceNumber: map['reference_number']?.toString() ?? '',
      status: InboxStatus.fromString(map['status']?.toString() ?? 'PENDING'),
      createdAt: parseDate(map['created_at']),
      syncedAt: map['synced_at'] != null ? parseDate(map['synced_at']) : null,
    );
  }

  /// Serializes into a Firestore update/insert map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bank_name': bankName,
      'account_type': accountType,
      'account_mask': accountMask,
      'merchant': merchant,
      'amount_cents': amountCents,
      'amount': amount,
      'currency': currency,
      'type': type,
      'category_suggestion': categorySuggestion,
      'transaction_date': transactionDate.toIso8601String(),
      'reference_number': referenceNumber,
      'status': status.toFirestoreString(),
      'created_at': createdAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }
}
