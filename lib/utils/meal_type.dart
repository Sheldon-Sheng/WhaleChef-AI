// lib/utils/meal_type.dart
import '../l10n/app_language.dart';

/// 兼容中英文的餐次判断(AI 在不同语言下输出不同 token)。
bool isBreakfastMeal(String t) => t == '早餐' || t == 'Breakfast';
bool isLunchMeal(String t) => t == '午餐' || t == 'Lunch';
bool isDinnerMeal(String t) => t == '晚餐' || t == 'Dinner';

/// 当前语言下生成对话框的默认菜系。
String defaultCuisineStyle() => AppLanguage.isEnglish ? 'Western' : '中餐';
