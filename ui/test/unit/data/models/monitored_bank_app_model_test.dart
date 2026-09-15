import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/domain/entities/monitored_bank_app.dart';
import 'package:finance_tracker/data/models/monitored_bank_app_model.dart';

void main() {
  group('MonitoredBankAppModel Serialization & Entity Mapping', () {
    final now = DateTime.parse('2026-09-14T20:00:00.000Z');

    test('converts fromEntity and toEntity accurately', () {
      final entity = MonitoredBankApp(
        id: 'nubank',
        packageName: 'com.nu.production',
        displayName: 'Nubank',
        isEnabled: true,
        createdAt: now,
      );

      final model = MonitoredBankAppModel.fromEntity(entity);
      expect(model.id, 'nubank');
      expect(model.packageName, 'com.nu.production');
      expect(model.displayName, 'Nubank');
      expect(model.isEnabled, isTrue);
      expect(model.createdAt, now);

      final backToEntity = model.toEntity();
      expect(backToEntity, equals(entity));
    });

    test('serializes toMap and deserializes fromMap roundtrip', () {
      final model = MonitoredBankAppModel(
        id: 'nequi',
        packageName: 'com.nequi.MobileApp',
        displayName: 'Nequi',
        isEnabled: false,
        createdAt: now,
      );

      final map = model.toMap();
      expect(map['id'], 'nequi');
      expect(map['package_name'], 'com.nequi.MobileApp');
      expect(map['display_name'], 'Nequi');
      expect(map['is_enabled'], 0);
      expect(map['created_at'], '2026-09-14T20:00:00.000Z');

      final deserialized = MonitoredBankAppModel.fromMap(map);
      expect(deserialized.id, 'nequi');
      expect(deserialized.packageName, 'com.nequi.MobileApp');
      expect(deserialized.displayName, 'Nequi');
      expect(deserialized.isEnabled, isFalse);
      expect(deserialized.createdAt, now);
    });

    test('copyWith updates fields correctly', () {
      final entity = MonitoredBankApp(
        id: 'nubank',
        packageName: 'com.nu.production',
        displayName: 'Nubank',
        isEnabled: true,
        createdAt: now,
      );

      final updated = entity.copyWith(isEnabled: false, displayName: 'Nu Colombia');
      expect(updated.isEnabled, isFalse);
      expect(updated.displayName, 'Nu Colombia');
      expect(updated.id, 'nubank');
    });
  });
}
