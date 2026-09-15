/// Entity representing a registered banking or fintech application monitored for push notifications.
class MonitoredBankApp {
  final String id;
  final String packageName;
  final String displayName;
  final bool isEnabled;
  final DateTime createdAt;

  const MonitoredBankApp({
    required this.id,
    required this.packageName,
    required this.displayName,
    this.isEnabled = true,
    required this.createdAt,
  });

  MonitoredBankApp copyWith({
    String? id,
    String? packageName,
    String? displayName,
    bool? isEnabled,
    DateTime? createdAt,
  }) {
    return MonitoredBankApp(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      displayName: displayName ?? this.displayName,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonitoredBankApp &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          packageName == other.packageName &&
          displayName == other.displayName &&
          isEnabled == other.isEnabled &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, packageName, displayName, isEnabled, createdAt);

  @override
  String toString() =>
      'MonitoredBankApp(id: $id, packageName: $packageName, displayName: $displayName, isEnabled: $isEnabled)';
}
