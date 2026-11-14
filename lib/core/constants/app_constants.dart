import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CategoryDef {
  const CategoryDef(this.key, this.icon, this.color);

  final String key;
  final IconData icon;
  final Color color;
}

const List<CategoryDef> taskCategories = [
  CategoryDef('work', Icons.work_outline_rounded, AppColors.info),
  CategoryDef('personal', Icons.person_outline_rounded, AppColors.roseGold),
  CategoryDef('health', Icons.health_and_safety_outlined, AppColors.success),
  CategoryDef('learning', Icons.school_outlined, AppColors.warning),
  CategoryDef('finance', Icons.payments_outlined, AppColors.copper),
  CategoryDef('other', Icons.category_outlined, AppColors.textSecondary),
];

const List<CategoryDef> incomeCategories = [
  CategoryDef('salary', Icons.badge_outlined, AppColors.success),
  CategoryDef('freelance', Icons.laptop_outlined, AppColors.info),
  CategoryDef('gift', Icons.card_giftcard_outlined, AppColors.roseGold),
  CategoryDef('investment', Icons.trending_up_outlined, AppColors.copper),
  CategoryDef('other_income', Icons.add_circle_outline_rounded, AppColors.textSecondary),
];

const List<CategoryDef> expenseCategories = [
  CategoryDef('food', Icons.restaurant_outlined, AppColors.warning),
  CategoryDef('transport', Icons.directions_bus_outlined, AppColors.info),
  CategoryDef('home', Icons.home_outlined, AppColors.roseGold),
  CategoryDef('health_care', Icons.medical_services_outlined, AppColors.success),
  CategoryDef('education', Icons.menu_book_outlined, AppColors.warning),
  CategoryDef('entertainment', Icons.sports_esports_outlined, AppColors.violet),
  CategoryDef('shopping', Icons.shopping_bag_outlined, AppColors.danger),
  CategoryDef('other_expense', Icons.remove_circle_outline_rounded, AppColors.textSecondary),
];

const List<CategoryDef> _allCategories = [
  ...taskCategories,
  ...incomeCategories,
  ...expenseCategories,
];

CategoryDef categoryDef(String key) =>
    _allCategories.firstWhere((c) => c.key == key, orElse: () => taskCategories.last);

String categoryL10nKey(String key) => 'cat_$key';

Color priorityColor(int priority) {
  switch (priority) {
    case 2:
      return AppColors.danger;
    case 1:
      return AppColors.warning;
    default:
      return AppColors.textSecondary;
  }
}

String priorityL10nKey(int priority) {
  switch (priority) {
    case 2:
      return 'priority_high';
    case 1:
      return 'priority_medium';
    default:
      return 'priority_low';
  }
}

class MoodDef {
  const MoodDef(this.key, this.icon, this.color);

  final String key;
  final IconData icon;
  final Color color;
}

const List<MoodDef> moods = [
  MoodDef('great', Icons.sentiment_very_satisfied_rounded, AppColors.success),
  MoodDef('good', Icons.sentiment_satisfied_rounded, AppColors.info),
  MoodDef('neutral', Icons.sentiment_neutral_rounded, AppColors.textSecondary),
  MoodDef('bad', Icons.sentiment_dissatisfied_rounded, AppColors.warning),
  MoodDef('awful', Icons.sentiment_very_dissatisfied_rounded, AppColors.danger),
];

MoodDef moodDef(String key) => moods.firstWhere((m) => m.key == key, orElse: () => moods[2]);
