import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/presentation/screens/dashboard/dashboard_screen.dart';

void main() {
  group('DashboardScreen Widget Tests', () {
    testWidgets('renders app bar title and placeholder content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      expect(find.text('Finance Tracker'), findsOneWidget);
      expect(find.text('Finance Tracker Dashboard'), findsOneWidget);
    });
  });
}
