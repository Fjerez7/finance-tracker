import 'package:flutter/material.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';

void main() {
  runApp(const FinanceTrackerApp());
}

/// The root application widget for Finance Tracker.
/// Configures high-level theming, title, and initial routing conforming to SPEC 00001.
class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DashboardScreen(),
    );
  }
}
