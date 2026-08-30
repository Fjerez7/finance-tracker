import 'package:flutter/material.dart';

/// Initial placeholder dashboard screen for the Finance Tracker application.
/// Complies with Clean Architecture presentation layer guidelines in SPEC 00001.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Tracker'),
      ),
      body: const Center(
        child: Text(
          'Finance Tracker Dashboard',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
