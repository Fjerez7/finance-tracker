import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/presentation/widgets/common/calculator_numpad.dart';

void main() {
  group('CalculatorNumpad Widget Tests', () {
    testWidgets('renders all numerical and operator keys', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CalculatorNumpad(onAmountChanged: (_) {})),
        ),
      );

      // Verify digits
      for (int i = 0; i <= 9; i++) {
        expect(find.text(i.toString()), findsOneWidget);
      }

      // Verify actions & operators
      expect(find.text('C'), findsOneWidget);
      expect(find.text('+'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
      expect(find.text('×'), findsOneWidget);
      expect(find.text('÷'), findsOneWidget);
      expect(find.text('='), findsOneWidget);
      expect(find.text('.'), findsOneWidget);
      expect(find.text('00'), findsOneWidget);
    });

    testWidgets('typing digits updates amount correctly', (
      WidgetTester tester,
    ) async {
      int recordedCents = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculatorNumpad(
              onAmountChanged: (cents) {
                recordedCents = cents;
              },
            ),
          ),
        ),
      );

      // Tap '4', '5', '.', '5' -> 45.50 -> 4550 cents
      await tester.tap(find.text('4'));
      await tester.pump();
      expect(recordedCents, equals(400));

      await tester.tap(find.text('5'));
      await tester.pump();
      expect(recordedCents, equals(4500));

      await tester.tap(find.text('.'));
      await tester.pump();

      await tester.tap(find.text('5'));
      await tester.pump();
      expect(recordedCents, equals(4550));
    });

    testWidgets('evaluates addition expression', (WidgetTester tester) async {
      int recordedCents = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculatorNumpad(
              onAmountChanged: (cents) {
                recordedCents = cents;
              },
            ),
          ),
        ),
      );

      // 10 + 5 = 15 -> 1500 cents
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('0'));
      await tester.pump();

      await tester.tap(find.text('+'));
      await tester.pump();

      await tester.tap(find.text('5'));
      await tester.pump();

      await tester.tap(find.text('='));
      await tester.pump();

      expect(recordedCents, equals(1500));
    });

    testWidgets('clear button resets input to 0', (WidgetTester tester) async {
      int recordedCents = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculatorNumpad(
              onAmountChanged: (cents) {
                recordedCents = cents;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('9'));
      await tester.pump();
      await tester.tap(find.text('9'));
      await tester.pump();
      expect(recordedCents, equals(9900));

      await tester.tap(find.text('C'));
      await tester.pump();
      expect(recordedCents, equals(0));
    });
  });
}
