import 'package:flutter/material.dart';

/// Helper mapping icon key strings to Material [IconData].
class IconHelper {
  IconHelper._();

  static const Map<String, IconData> accountIcons = {
    'account_balance': Icons.account_balance,
    'account_balance_wallet': Icons.account_balance_wallet,
    'credit_card': Icons.credit_card,
    'payments': Icons.payments,
    'savings': Icons.savings,
    'attach_money': Icons.attach_money,
    'store': Icons.store,
    'shopping_bag': Icons.shopping_bag,
    'monetization_on': Icons.monetization_on,
    'wallet': Icons.wallet,
  };

  static const Map<String, IconData> categoryIcons = {
    'restaurant': Icons.restaurant,
    'shopping_cart': Icons.shopping_cart,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'bolt': Icons.bolt,
    'movie': Icons.movie,
    'local_hospital': Icons.local_hospital,
    'spa': Icons.spa,
    'shopping_bag': Icons.shopping_bag,
    'subscriptions': Icons.subscriptions,
    'more_horiz': Icons.more_horiz,
    'payments': Icons.payments,
    'work': Icons.work,
    'trending_up': Icons.trending_up,
    'attach_money': Icons.attach_money,
    'flight': Icons.flight,
    'school': Icons.school,
    'fitness_center': Icons.fitness_center,
  };

  /// Returns [IconData] corresponding to [name], falling back to [fallback].
  static IconData getIconData(
    String name, {
    IconData fallback = Icons.category,
  }) {
    if (accountIcons.containsKey(name)) {
      return accountIcons[name]!;
    }
    if (categoryIcons.containsKey(name)) {
      return categoryIcons[name]!;
    }
    return fallback;
  }
}
