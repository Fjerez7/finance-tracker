import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';

/// Helper to resolve localized names for default system categories.
class CategoryLocalizationHelper {
  CategoryLocalizationHelper._();

  /// Returns the localized name for a category based on its ID or English name,
  /// falling back to the stored custom name for user-created categories.
  static String getLocalizedName(
    BuildContext context, {
    required String? categoryId,
    required String defaultName,
  }) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return defaultName;

    switch (categoryId) {
      case 'cat_default_food':
        return l10n.categoryFoodDining;
      case 'cat_default_groceries':
        return l10n.categoryGroceries;
      case 'cat_default_transport':
        return l10n.categoryTransportation;
      case 'cat_default_housing':
        return l10n.categoryHousing;
      case 'cat_default_utilities':
        return l10n.categoryUtilities;
      case 'cat_default_entertainment':
        return l10n.categoryEntertainment;
      case 'cat_default_health':
        return l10n.categoryHealthcare;
      case 'cat_default_shopping':
        return l10n.categoryShopping;
      case 'cat_default_personal':
        return l10n.categoryPersonalCare;
      case 'cat_default_education':
        return l10n.categoryEducation;
      case 'cat_default_travel':
        return l10n.categoryTravel;
      case 'cat_default_other_expense':
        return l10n.categoryOtherExpense;
      case 'cat_default_salary':
        return l10n.categorySalary;
      case 'cat_default_freelance':
        return l10n.categoryFreelance;
      case 'cat_default_investments':
        return l10n.categoryInvestments;
      case 'cat_default_other_income':
        return l10n.categoryOtherIncome;
      default:
        switch (defaultName.trim().toLowerCase()) {
          case 'food & dining':
            return l10n.categoryFoodDining;
          case 'groceries':
            return l10n.categoryGroceries;
          case 'transportation':
            return l10n.categoryTransportation;
          case 'housing & rent':
          case 'housing':
            return l10n.categoryHousing;
          case 'utilities':
            return l10n.categoryUtilities;
          case 'entertainment':
            return l10n.categoryEntertainment;
          case 'healthcare':
          case 'health':
            return l10n.categoryHealthcare;
          case 'shopping':
            return l10n.categoryShopping;
          case 'personal care':
            return l10n.categoryPersonalCare;
          case 'education':
            return l10n.categoryEducation;
          case 'travel':
            return l10n.categoryTravel;
          case 'other expense':
            return l10n.categoryOtherExpense;
          case 'salary':
            return l10n.categorySalary;
          case 'freelance':
            return l10n.categoryFreelance;
          case 'investments':
            return l10n.categoryInvestments;
          case 'other income':
            return l10n.categoryOtherIncome;
          default:
            return defaultName;
        }
    }
  }
}
