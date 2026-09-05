import 'package:flutter/material.dart';

/// Helper for parsing and formatting hex color strings.
class ColorHelper {
  ColorHelper._();

  /// Default preset colors available in account and category pickers.
  static const List<String> presetColors = [
    '#4CAF50', // Green
    '#2196F3', // Blue
    '#9C27B0', // Purple
    '#FF9800', // Orange
    '#E91E63', // Pink
    '#00BCD4', // Cyan
    '#3F51B5', // Indigo
    '#607D8B', // Blue Grey
    '#795548', // Brown
    '#F44336', // Red
  ];

  /// Parses a hex color string (e.g. "#4CAF50" or "4CAF50") into a Flutter [Color].
  static Color hexToColor(
    String hexString, {
    Color fallback = const Color(0xFF2196F3),
  }) {
    try {
      final String cleanHex = hexString.replaceAll('#', '').trim();
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      } else if (cleanHex.length == 8) {
        return Color(int.parse(cleanHex, radix: 16));
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  /// Converts a Flutter [Color] to a hex string (e.g. "#4CAF50").
  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
