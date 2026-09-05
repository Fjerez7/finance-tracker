import '../../core/constants/database_constants.dart';
import '../../domain/entities/transaction.dart';

/// Data model for [Transaction] entity handling SQLite map and JSON serialization.
class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.accountId,
    super.toAccountId,
    super.categoryId,
    required super.amountCents,
    required super.type,
    super.description = '',
    required super.transactionDate,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [TransactionModel] from a domain [Transaction] entity.
  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      accountId: entity.accountId,
      toAccountId: entity.toAccountId,
      categoryId: entity.categoryId,
      amountCents: entity.amountCents,
      type: entity.type,
      description: entity.description,
      transactionDate: entity.transactionDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Deserializes SQLite row map into [TransactionModel].
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map[DatabaseConstants.colId] as String,
      accountId: map[DatabaseConstants.colAccountId] as String,
      toAccountId: map[DatabaseConstants.colToAccountId] as String?,
      categoryId: map[DatabaseConstants.colCategoryId] as String?,
      amountCents: (map[DatabaseConstants.colAmountCents] as num).toInt(),
      type: TransactionType.fromString(
        map[DatabaseConstants.colTransactionType] as String,
      ),
      description: map[DatabaseConstants.colDescription] as String? ?? '',
      transactionDate: DateTime.parse(
        map[DatabaseConstants.colTransactionDate] as String,
      ).toUtc(),
      createdAt: DateTime.parse(
        map[DatabaseConstants.colCreatedAt] as String,
      ).toUtc(),
      updatedAt: DateTime.parse(
        map[DatabaseConstants.colUpdatedAt] as String,
      ).toUtc(),
    );
  }

  /// Serializes [TransactionModel] to SQLite row map.
  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colAccountId: accountId,
      DatabaseConstants.colToAccountId: toAccountId,
      DatabaseConstants.colCategoryId: categoryId,
      DatabaseConstants.colAmountCents: amountCents,
      DatabaseConstants.colTransactionType: type.toDbString(),
      DatabaseConstants.colDescription: description,
      DatabaseConstants.colTransactionDate: transactionDate
          .toUtc()
          .toIso8601String(),
      DatabaseConstants.colCreatedAt: createdAt.toUtc().toIso8601String(),
      DatabaseConstants.colUpdatedAt: updatedAt.toUtc().toIso8601String(),
    };
  }

  /// Converts this data model to a pure domain [Transaction] entity.
  Transaction toEntity() {
    return Transaction(
      id: id,
      accountId: accountId,
      toAccountId: toAccountId,
      categoryId: categoryId,
      amountCents: amountCents,
      type: type,
      description: description,
      transactionDate: transactionDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
