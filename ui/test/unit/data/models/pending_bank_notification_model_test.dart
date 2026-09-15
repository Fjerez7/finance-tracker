import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/data/models/pending_bank_notification_model.dart';

void main() {
  group('PendingBankNotification Serialization Tests', () {
    final now = DateTime.parse('2026-09-14T20:00:00.000Z');

    test('serializes toMap and deserializes fromMap roundtrip accurately', () {
      final notif = PendingBankNotification(
        id: 'pnotif_123',
        packageName: 'com.nu.production',
        notificationKey: 'com.nu.production_1726359000000_1001',
        title: 'Compra aprobada por \$20.100,00',
        body: 'Tu compra en BACOOS MARKET LINDEROS por \$20.100,00 con tu tarjeta terminada en 1394 ha sido APROBADA.',
        postTime: 1726359000000,
        isProcessed: false,
        createdAt: now,
      );

      final map = notif.toMap();
      expect(map['id'], 'pnotif_123');
      expect(map['package_name'], 'com.nu.production');
      expect(map['notification_key'], 'com.nu.production_1726359000000_1001');
      expect(map['title'], 'Compra aprobada por \$20.100,00');
      expect(map['body'], contains('BACOOS MARKET'));
      expect(map['post_time'], 1726359000000);
      expect(map['is_processed'], 0);
      expect(map['created_at'], '2026-09-14T20:00:00.000Z');

      final deserialized = PendingBankNotification.fromMap(map);
      expect(deserialized, equals(notif));
    });

    test('copyWith updates isProcessed status correctly', () {
      final notif = PendingBankNotification(
        id: 'pnotif_123',
        packageName: 'com.nu.production',
        notificationKey: 'com.nu.production_1726359000000_1001',
        title: 'Compra aprobada',
        body: 'Compra aprobada',
        postTime: 1726359000000,
        isProcessed: false,
        createdAt: now,
      );

      final updated = notif.copyWith(isProcessed: true);
      expect(updated.isProcessed, isTrue);
      expect(updated.id, 'pnotif_123');
    });
  });
}
