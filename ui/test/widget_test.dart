import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/main.dart';
import 'package:finance_tracker/presentation/screens/dashboard/dashboard_screen.dart';

void main() {
  testWidgets('FinanceTrackerApp smoke test renders DashboardScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceTrackerApp());

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Finance Tracker'), findsOneWidget);
    expect(find.text('Finance Tracker Dashboard'), findsOneWidget);
  });
}
