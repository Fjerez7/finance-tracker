/// Supported account classifications.
enum AccountType {
  bank,
  digitalWallet,
  cash,
  creditCard;

  static AccountType fromString(String value) {
    switch (value) {
      case 'bank':
        return AccountType.bank;
      case 'digital_wallet':
      case 'digitalWallet':
        return AccountType.digitalWallet;
      case 'cash':
        return AccountType.cash;
      case 'credit_card':
      case 'creditCard':
        return AccountType.creditCard;
      default:
        throw ArgumentError('Unknown AccountType: $value');
    }
  }

  String toDbString() {
    switch (this) {
      case AccountType.bank:
        return 'bank';
      case AccountType.digitalWallet:
        return 'digital_wallet';
      case AccountType.cash:
        return 'cash';
      case AccountType.creditCard:
        return 'credit_card';
    }
  }
}

/// Domain entity representing a financial account, wallet, or revolving credit line.
class Account {
  final String id;
  final String name;
  final AccountType type;
  final int balanceCents;
  final int creditLimitCents;
  final String currency;
  final String colorHex;
  final String iconName;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balanceCents,
    this.creditLimitCents = 0,
    required this.currency,
    required this.colorHex,
    required this.iconName,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCreditCard => type == AccountType.creditCard;

  /// Available credit in cents. Only applicable for credit cards.
  int get availableCreditCents =>
      isCreditCard ? creditLimitCents - balanceCents : 0;

  /// Credit utilization rate between 0.0 and 1.0 (or >1.0 if over limit).
  double get creditUtilizationRate => (isCreditCard && creditLimitCents > 0)
      ? (balanceCents / creditLimitCents).clamp(0.0, 1.0)
      : 0.0;

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    int? balanceCents,
    int? creditLimitCents,
    String? currency,
    String? colorHex,
    String? iconName,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balanceCents: balanceCents ?? this.balanceCents,
      creditLimitCents: creditLimitCents ?? this.creditLimitCents,
      currency: currency ?? this.currency,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          balanceCents == other.balanceCents &&
          creditLimitCents == other.creditLimitCents &&
          currency == other.currency &&
          colorHex == other.colorHex &&
          iconName == other.iconName &&
          isArchived == other.isArchived &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      balanceCents.hashCode ^
      creditLimitCents.hashCode ^
      currency.hashCode ^
      colorHex.hashCode ^
      iconName.hashCode ^
      isArchived.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'Account(id: $id, name: $name, type: $type, balanceCents: $balanceCents, creditLimitCents: $creditLimitCents, currency: $currency, isArchived: $isArchived)';
  }
}
