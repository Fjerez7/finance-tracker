import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

void main() {
  group('Configuration & Dependencies Test', () {
    test('path package helper functions as expected', () {
      final joined = p.join('assets', 'icons', 'test.png');
      expect(joined, contains('assets'));
      expect(joined, contains('icons'));
    });

    test('intl DateFormat functions as expected', () {
      final date = DateTime.utc(2026, 8, 30);
      final formatted = DateFormat('yyyy-MM-dd').format(date);
      expect(formatted, equals('2026-08-30'));
    });

    test('provider types and foundation are resolvable', () {
      expect(ChangeNotifier, isNotNull);
      expect(Provider, isNotNull);
    });
  });
}
