// lib/utils/default_seasonings.dart
import '../l10n/app_language.dart';

/// 默认常用调味料(中餐 + 西餐 + 日式) —— 中文版
const List<String> kDefaultSeasoningsZh = [
  // 中餐
  '盐', '白糖', '酱油', '老抽', '生抽', '醋', '料酒', '蚝油',
  '豆瓣酱', '甜面酱', '辣椒酱', '芝麻油', '花椒油', '鸡精', '味精',
  '五香粉', '十三香', '白胡椒粉', '黑胡椒粉', '八角', '桂皮', '香叶',
  '干辣椒', '花椒', '淀粉', '老姜', '大蒜', '葱',
  // 西餐
  '橄榄油', '黄油', '黑胡椒碎', '迷迭香', '百里香', '罗勒', '欧芹',
  '牛至', '肉桂粉', '肉豆蔻', '披萨草', '香草精', '柠檬汁',
  // 日式
  '味噌', '味醂', '清酒', '日式酱油', '寿司醋', '芝麻酱',
  '柴鱼片', '昆布', '七味粉', '芥末', '照烧酱', '天妇罗粉',
];

/// 默认常用调味料 —— 英文版(顺序与中文一致)
const List<String> kDefaultSeasoningsEn = [
  // Chinese
  'Salt', 'Granulated sugar', 'Soy sauce', 'Dark soy sauce', 'Light soy sauce',
  'Vinegar', 'Cooking wine', 'Oyster sauce', 'Doubanjiang', 'Sweet bean paste',
  'Chili sauce', 'Sesame oil', 'Sichuan pepper oil', 'Chicken bouillon', 'MSG',
  'Five-spice powder', 'Thirteen-spice powder', 'White pepper', 'Black pepper',
  'Star anise',
  'Cinnamon bark',
  'Bay leaf',
  'Dried chili',
  'Sichuan peppercorns',
  'Starch', 'Ginger', 'Garlic', 'Scallion',
  // Western
  'Olive oil', 'Butter', 'Black pepper flakes', 'Rosemary', 'Thyme', 'Basil',
  'Parsley', 'Oregano', 'Cinnamon powder', 'Nutmeg', 'Pizza herb',
  'Vanilla extract', 'Lemon juice',
  // Japanese
  'Miso', 'Mirin', 'Sake', 'Japanese soy sauce', 'Sushi vinegar',
  'Sesame paste', 'Bonito flakes', 'Kombu', 'Shichimi togarashi', 'Wasabi',
  'Teriyaki sauce', 'Tempura batter',
];

/// 当前语言下的默认调味料列表。
List<String> get defaultSeasonings =>
    AppLanguage.isEnglish ? kDefaultSeasoningsEn : kDefaultSeasoningsZh;
