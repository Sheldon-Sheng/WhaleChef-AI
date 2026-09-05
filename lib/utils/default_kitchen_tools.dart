// lib/utils/default_kitchen_tools.dart
import '../l10n/app_language.dart';

/// 默认常用厨具 —— 中文版
const List<String> kDefaultKitchenToolsZh = [
  '炒锅',
  '汤锅',
  '平底锅',
  '蒸锅',
  '电饭煲',
  '菜刀',
  '水果刀',
  '砧板',
  '削皮刀',
  '厨房剪刀',
  '锅铲',
  '汤勺',
  '漏勺',
  '打蛋器',
  '搅拌碗',
  '擀面杖',
  '烤箱',
  '微波炉',
  '空气炸锅',
  '电水壶',
];

/// 默认常用厨具 —— 英文版(顺序与中文一致)
const List<String> kDefaultKitchenToolsEn = [
  'Wok',
  'Stock pot',
  'Frying pan',
  'Steamer',
  'Rice cooker',
  "Chef's knife",
  'Paring knife',
  'Cutting board',
  'Peeler',
  'Kitchen scissors',
  'Spatula',
  'Ladle',
  'Skimmer',
  'Whisk',
  'Mixing bowl',
  'Rolling pin',
  'Oven',
  'Microwave',
  'Air fryer',
  'Electric kettle',
];

/// 当前语言下的默认厨具列表。
List<String> get defaultKitchenTools =>
    AppLanguage.isEnglish ? kDefaultKitchenToolsEn : kDefaultKitchenToolsZh;
