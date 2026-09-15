import '../../core/constants/database_constants.dart';

/// Data model representing an intercepted banking push notification stored in the offline buffer.
class PendingBankNotification {
  final String id;
  final String packageName;
  final String notificationKey;
  final String? title;
  final String body;
  final int postTime;
  final bool isProcessed;
  final DateTime createdAt;

  const PendingBankNotification({
    required this.id,
    required this.packageName,
    required this.notificationKey,
    this.title,
    required this.body,
    required this.postTime,
    this.isProcessed = false,
    required this.createdAt,
  });

  /// Factory creating instance from SQLite map row.
  factory PendingBankNotification.fromMap(Map<String, dynamic> map) {
    return PendingBankNotification(
      id: map[DatabaseConstants.colId] as String,
      packageName: map[DatabaseConstants.colPackageName] as String,
      notificationKey: map[DatabaseConstants.colNotificationKey] as String,
      title: map[DatabaseConstants.colTitle] as String?,
      body: map[DatabaseConstants.colBody] as String,
      postTime: map[DatabaseConstants.colPostTime] as int,
      isProcessed: (map[DatabaseConstants.colIsProcessed] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map[DatabaseConstants.colCreatedAt] as String),
    );
  }

  /// Converts instance to SQLite-compatible map.
  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.colId: id,
      DatabaseConstants.colPackageName: packageName,
      DatabaseConstants.colNotificationKey: notificationKey,
      DatabaseConstants.colTitle: title,
      DatabaseConstants.colBody: body,
      DatabaseConstants.colPostTime: postTime,
      DatabaseConstants.colIsProcessed: isProcessed ? 1 : 0,
      DatabaseConstants.colCreatedAt: createdAt.toIso8601String(),
    };
  }

  PendingBankNotification copyWith({
    String? id,
    String? packageName,
    String? notificationKey,
    String? title,
    String? body,
    int? postTime,
    bool? isProcessed,
    DateTime? createdAt,
  }) {
    return PendingBankNotification(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      notificationKey: notificationKey ?? this.notificationKey,
      title: title ?? this.title,
      body: body ?? this.body,
      postTime: postTime ?? this.postTime,
      isProcessed: isProcessed ?? this.isProcessed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingBankNotification &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          packageName == other.packageName &&
          notificationKey == other.notificationKey &&
          title == other.title &&
          body == other.body &&
          postTime == other.postTime &&
          isProcessed == other.isProcessed &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        packageName,
        notificationKey,
        title,
        body,
        postTime,
        isProcessed,
        createdAt,
      );
}
