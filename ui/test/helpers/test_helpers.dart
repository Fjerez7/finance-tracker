import 'package:flutter/material.dart';
import 'package:finance_tracker/l10n/generated/app_localizations.dart';

/// Wraps a widget with MaterialApp configured with AppLocalizations for testing.
Widget createTestableWidget({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}
