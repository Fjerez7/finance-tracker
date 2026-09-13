/// Lifecycle status for staged inbox transactions.
enum InboxStatus {
  pending,
  synced,
  discarded;

  static InboxStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return InboxStatus.pending;
      case 'SYNCED':
        return InboxStatus.synced;
      case 'DISCARDED':
        return InboxStatus.discarded;
      default:
        return InboxStatus.pending;
    }
  }

  String toFirestoreString() {
    switch (this) {
      case InboxStatus.pending:
        return 'PENDING';
      case InboxStatus.synced:
        return 'SYNCED';
      case InboxStatus.discarded:
        return 'DISCARDED';
    }
  }
}

/// Domain entity representing a transaction extracted from email and staged in Firestore.
class InboxTransaction {
  final String id;
  final String bankName;
  final String accountType;
  final String accountMask;
  final String merchant;
  final int amountCents;
  final double amount;
  final String currency;
  final String type;
  final String categorySuggestion;
  final DateTime transactionDate;
  final String referenceNumber;
  final InboxStatus status;
  final DateTime createdAt;
  final DateTime? syncedAt;

  const InboxTransaction({
    required this.id,
    required this.bankName,
    required this.accountType,
    required this.accountMask,
    required this.merchant,
    required this.amountCents,
    required this.amount,
    required this.currency,
    required this.type,
    required this.categorySuggestion,
    required this.transactionDate,
    required this.referenceNumber,
    required this.status,
    required this.createdAt,
    this.syncedAt,
  });

  bool get isExpense => type.toLowerCase() == 'expense';
  bool get isIncome => type.toLowerCase() == 'income';
  bool get isTransfer => type.toLowerCase() == 'transfer';
  bool get isPending => status == InboxStatus.pending;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InboxTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          bankName == other.bankName &&
          accountMask == other.accountMask &&
          amountCents == other.amountCents &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      bankName.hashCode ^
      accountMask.hashCode ^
      amountCents.hashCode ^
      status.hashCode;

  @override
  String toString() {
    return 'InboxTransaction(id: $id, bank: $bankName, mask: $accountMask, merchant: $merchant, amountCents: $amountCents, status: $status)';
  }
}
