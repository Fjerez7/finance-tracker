/// Classification of financial movement.
enum TransactionType {
  expense,
  income,
  transfer;

  static TransactionType fromString(String value) {
    switch (value) {
      case 'expense':
        return TransactionType.expense;
      case 'income':
        return TransactionType.income;
      case 'transfer':
        return TransactionType.transfer;
      default:
        throw ArgumentError('Unknown TransactionType: $value');
    }
  }

  String toDbString() {
    switch (this) {
      case TransactionType.expense:
        return 'expense';
      case TransactionType.income:
        return 'income';
      case TransactionType.transfer:
        return 'transfer';
    }
  }
}

/// Domain entity representing a financial transaction (expense, income, or transfer).
class Transaction {
  final String id;
  final String accountId;
  final String? toAccountId;
  final String? categoryId;
  final int amountCents;
  final TransactionType type;
  final String description;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.accountId,
    this.toAccountId,
    this.categoryId,
    required this.amountCents,
    required this.type,
    this.description = '',
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(
         type != TransactionType.transfer ||
             (toAccountId != null && toAccountId != accountId),
         'Transfer transaction requires a valid destination account different from source',
       ),
       assert(
         amountCents > 0,
         'Transaction amount must be strictly positive (> 0)',
       );

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
  bool get isTransfer => type == TransactionType.transfer;

  Transaction copyWith({
    String? id,
    String? accountId,
    String? toAccountId,
    String? categoryId,
    int? amountCents,
    TransactionType? type,
    String? description,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      categoryId: categoryId ?? this.categoryId,
      amountCents: amountCents ?? this.amountCents,
      type: type ?? this.type,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          accountId == other.accountId &&
          toAccountId == other.toAccountId &&
          categoryId == other.categoryId &&
          amountCents == other.amountCents &&
          type == other.type &&
          description == other.description &&
          transactionDate == other.transactionDate &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      accountId.hashCode ^
      toAccountId.hashCode ^
      categoryId.hashCode ^
      amountCents.hashCode ^
      type.hashCode ^
      description.hashCode ^
      transactionDate.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'Transaction(id: $id, accountId: $accountId, toAccountId: $toAccountId, categoryId: $categoryId, amountCents: $amountCents, type: $type, date: $transactionDate)';
  }
}
