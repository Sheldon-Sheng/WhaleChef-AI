import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'肥鱼大厨'**
  String get appTitle;

  /// No description provided for @tabRecipes.
  ///
  /// In zh, this message translates to:
  /// **'菜谱'**
  String get tabRecipes;

  /// No description provided for @tabFridge.
  ///
  /// In zh, this message translates to:
  /// **'冰箱'**
  String get tabFridge;

  /// No description provided for @tabKitchen.
  ///
  /// In zh, this message translates to:
  /// **'厨房'**
  String get tabKitchen;

  /// No description provided for @tabStats.
  ///
  /// In zh, this message translates to:
  /// **'统计'**
  String get tabStats;

  /// No description provided for @tabSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get tabSettings;

  /// No description provided for @statsTitle.
  ///
  /// In zh, this message translates to:
  /// **'每周卡路里统计'**
  String get statsTitle;

  /// No description provided for @statsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据，完成一次烹饪后在这里查看统计。'**
  String get statsEmpty;

  /// No description provided for @statsCaloriesUnit.
  ///
  /// In zh, this message translates to:
  /// **'千卡'**
  String get statsCaloriesUnit;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有菜谱计划'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'告诉我你的身体数据和饮食偏好，\n我来为你定制一周健康菜谱。'**
  String get homeEmptySubtitle;

  /// No description provided for @homeGeneratePlan.
  ///
  /// In zh, this message translates to:
  /// **'生成一周菜谱'**
  String get homeGeneratePlan;

  /// No description provided for @homeStartSetup.
  ///
  /// In zh, this message translates to:
  /// **'开始设置'**
  String get homeStartSetup;

  /// No description provided for @genDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'菜谱要求'**
  String get genDialogTitle;

  /// No description provided for @genDishesLabel.
  ///
  /// In zh, this message translates to:
  /// **'几道菜'**
  String get genDishesLabel;

  /// No description provided for @genDishCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 道'**
  String genDishCount(int count);

  /// No description provided for @genMeatDishes.
  ///
  /// In zh, this message translates to:
  /// **'荤菜'**
  String get genMeatDishes;

  /// No description provided for @genVeggieDishes.
  ///
  /// In zh, this message translates to:
  /// **'素菜'**
  String get genVeggieDishes;

  /// No description provided for @genAddSoup.
  ///
  /// In zh, this message translates to:
  /// **'加汤'**
  String get genAddSoup;

  /// No description provided for @genCookTimeLabel.
  ///
  /// In zh, this message translates to:
  /// **'烹饪时间限制（分钟）'**
  String get genCookTimeLabel;

  /// No description provided for @genCuisineLabel.
  ///
  /// In zh, this message translates to:
  /// **'菜品风格'**
  String get genCuisineLabel;

  /// No description provided for @cuisineChinese.
  ///
  /// In zh, this message translates to:
  /// **'中餐'**
  String get cuisineChinese;

  /// No description provided for @cuisineWestern.
  ///
  /// In zh, this message translates to:
  /// **'西餐'**
  String get cuisineWestern;

  /// No description provided for @cuisineJapanese.
  ///
  /// In zh, this message translates to:
  /// **'日式'**
  String get cuisineJapanese;

  /// No description provided for @genSelectMeals.
  ///
  /// In zh, this message translates to:
  /// **'请选择需要规划的餐次：'**
  String get genSelectMeals;

  /// No description provided for @mealBreakfast.
  ///
  /// In zh, this message translates to:
  /// **'早餐'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In zh, this message translates to:
  /// **'午餐'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In zh, this message translates to:
  /// **'晚餐'**
  String get mealDinner;

  /// No description provided for @genPreferFavorites.
  ///
  /// In zh, this message translates to:
  /// **'优先在收藏菜谱中选择'**
  String get genPreferFavorites;

  /// No description provided for @genFavoriteCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'优先使用收藏菜谱数量'**
  String get genFavoriteCountLabel;

  /// No description provided for @genFavoriteCountHelper.
  ///
  /// In zh, this message translates to:
  /// **'最多 {max} 道（一周共 {max} 餐）'**
  String genFavoriteCountHelper(int max);

  /// No description provided for @genFavoriteCountError.
  ///
  /// In zh, this message translates to:
  /// **'数字不能超过 {max}'**
  String genFavoriteCountError(int max);

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @genConfirm.
  ///
  /// In zh, this message translates to:
  /// **'生成菜谱'**
  String get genConfirm;

  /// No description provided for @weekdayMon.
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get weekdaySun;

  /// No description provided for @todayRecipes.
  ///
  /// In zh, this message translates to:
  /// **'今日菜谱'**
  String get todayRecipes;

  /// No description provided for @dayRecipeTitle.
  ///
  /// In zh, this message translates to:
  /// **'{day}菜谱'**
  String dayRecipeTitle(String day);

  /// No description provided for @shoppingListName.
  ///
  /// In zh, this message translates to:
  /// **'食材采购清单'**
  String get shoppingListName;

  /// No description provided for @shoppingListTitle.
  ///
  /// In zh, this message translates to:
  /// **'食材采购清单（{count} 项待购）'**
  String shoppingListTitle(int count);

  /// No description provided for @planTagDishes.
  ///
  /// In zh, this message translates to:
  /// **'{count} 道菜'**
  String planTagDishes(int count);

  /// No description provided for @planTagSoup.
  ///
  /// In zh, this message translates to:
  /// **'加汤'**
  String get planTagSoup;

  /// No description provided for @planTagMinutes.
  ///
  /// In zh, this message translates to:
  /// **'{min}min'**
  String planTagMinutes(int min);

  /// No description provided for @completeToday.
  ///
  /// In zh, this message translates to:
  /// **'已完成今天的烹饪'**
  String get completeToday;

  /// No description provided for @noRecipeToday.
  ///
  /// In zh, this message translates to:
  /// **'今日没有菜谱'**
  String get noRecipeToday;

  /// No description provided for @confirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认完成'**
  String get confirmTitle;

  /// No description provided for @confirmCookingBody.
  ///
  /// In zh, this message translates to:
  /// **'确认完成今日烹饪吗？\n\n将从冰箱扣除今日所需食材，不足部分从采购清单中扣除。'**
  String get confirmCookingBody;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @doneCookingToast.
  ///
  /// In zh, this message translates to:
  /// **'已完成今日烹饪！'**
  String get doneCookingToast;

  /// No description provided for @kitchenTabTools.
  ///
  /// In zh, this message translates to:
  /// **'厨具'**
  String get kitchenTabTools;

  /// No description provided for @kitchenTabSeasonings.
  ///
  /// In zh, this message translates to:
  /// **'调味料'**
  String get kitchenTabSeasonings;

  /// No description provided for @toolInitTitle.
  ///
  /// In zh, this message translates to:
  /// **'初始化厨具'**
  String get toolInitTitle;

  /// No description provided for @toolInitPrompt.
  ///
  /// In zh, this message translates to:
  /// **'已为您准备了常用厨具列表，请取消勾选您不需要的厨具：'**
  String get toolInitPrompt;

  /// No description provided for @kitchenEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有{type}，点击右下角 + 添加'**
  String kitchenEmpty(String type);

  /// No description provided for @kitchenTypeTool.
  ///
  /// In zh, this message translates to:
  /// **'厨具'**
  String get kitchenTypeTool;

  /// No description provided for @kitchenTypeSeasoning.
  ///
  /// In zh, this message translates to:
  /// **'调味料'**
  String get kitchenTypeSeasoning;

  /// No description provided for @kitchenAvailable.
  ///
  /// In zh, this message translates to:
  /// **'有'**
  String get kitchenAvailable;

  /// No description provided for @kitchenUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'无'**
  String get kitchenUnavailable;

  /// No description provided for @kitchenAddDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加{type}'**
  String kitchenAddDialogTitle(String type);

  /// No description provided for @kitchenName.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get kitchenName;

  /// No description provided for @add.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get add;

  /// No description provided for @seasoningInitTitle.
  ///
  /// In zh, this message translates to:
  /// **'初始化调味料'**
  String get seasoningInitTitle;

  /// No description provided for @seasoningInitPrompt.
  ///
  /// In zh, this message translates to:
  /// **'已为您准备了常用调味料列表，请取消勾选您不需要的调味料：'**
  String get seasoningInitPrompt;

  /// No description provided for @seasoningSkip.
  ///
  /// In zh, this message translates to:
  /// **'跳过'**
  String get seasoningSkip;

  /// No description provided for @seasoningConfirmAdd.
  ///
  /// In zh, this message translates to:
  /// **'确认添加（{count} 项）'**
  String seasoningConfirmAdd(int count);

  /// No description provided for @seasoningOutTitle.
  ///
  /// In zh, this message translates to:
  /// **'调味料用完'**
  String get seasoningOutTitle;

  /// No description provided for @seasoningOutBody.
  ///
  /// In zh, this message translates to:
  /// **'{name}已标记为\"无\"，并已加入采购清单。\n是否需要根据缺少调味料的情况重新规划本周剩余菜谱？'**
  String seasoningOutBody(String name);

  /// No description provided for @replan.
  ///
  /// In zh, this message translates to:
  /// **'重新规划'**
  String get replan;

  /// No description provided for @later.
  ///
  /// In zh, this message translates to:
  /// **'稍后再说'**
  String get later;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In zh, this message translates to:
  /// **'确定删除「{name}」吗？'**
  String deleteConfirmBody(String name);

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @fridgeAddTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加食材'**
  String get fridgeAddTitle;

  /// No description provided for @fridgeEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑食材'**
  String get fridgeEditTitle;

  /// No description provided for @fridgeName.
  ///
  /// In zh, this message translates to:
  /// **'食材名'**
  String get fridgeName;

  /// No description provided for @fridgeQty.
  ///
  /// In zh, this message translates to:
  /// **'数量（如: 500g、3个）'**
  String get fridgeQty;

  /// No description provided for @fridgeCategory.
  ///
  /// In zh, this message translates to:
  /// **'分类（可选）'**
  String get fridgeCategory;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @fridgeClearTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空冰箱'**
  String get fridgeClearTitle;

  /// No description provided for @fridgeClearBody.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空冰箱中所有食材吗？此操作不可撤销。'**
  String get fridgeClearBody;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get clear;

  /// No description provided for @fridgeEmpty.
  ///
  /// In zh, this message translates to:
  /// **'冰箱是空的，点击右上角 + 添加食材'**
  String get fridgeEmpty;

  /// No description provided for @fridgeUncategorized.
  ///
  /// In zh, this message translates to:
  /// **'未分类'**
  String get fridgeUncategorized;

  /// No description provided for @selectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In zh, this message translates to:
  /// **'取消全选'**
  String get deselectAll;

  /// No description provided for @selectedCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 项已选'**
  String selectedCount(int count);

  /// No description provided for @shoppingEmpty.
  ///
  /// In zh, this message translates to:
  /// **'采购清单为空'**
  String get shoppingEmpty;

  /// No description provided for @confirmPurchased.
  ///
  /// In zh, this message translates to:
  /// **'确认已购买'**
  String get confirmPurchased;

  /// No description provided for @purchaseSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已确认购买，食材已加入冰箱'**
  String get purchaseSuccess;

  /// No description provided for @purchaseFailed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败: {error}'**
  String purchaseFailed(String error);

  /// No description provided for @cookingSteps.
  ///
  /// In zh, this message translates to:
  /// **'烹饪步骤'**
  String get cookingSteps;

  /// No description provided for @noSteps.
  ///
  /// In zh, this message translates to:
  /// **'暂无详细步骤'**
  String get noSteps;

  /// No description provided for @ingredientList.
  ///
  /// In zh, this message translates to:
  /// **'食材清单'**
  String get ingredientList;

  /// No description provided for @noIngredients.
  ///
  /// In zh, this message translates to:
  /// **'无食材信息'**
  String get noIngredients;

  /// No description provided for @seasonings.
  ///
  /// In zh, this message translates to:
  /// **'调味品'**
  String get seasonings;

  /// No description provided for @profileTitle.
  ///
  /// In zh, this message translates to:
  /// **'个人信息'**
  String get profileTitle;

  /// No description provided for @profileUnset.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get profileUnset;

  /// No description provided for @profileAgeLabel.
  ///
  /// In zh, this message translates to:
  /// **'年龄: {age}'**
  String profileAgeLabel(int age);

  /// No description provided for @profileHeightLabel.
  ///
  /// In zh, this message translates to:
  /// **'身高: {height}cm 体重: {weight}kg'**
  String profileHeightLabel(double height, double weight);

  /// No description provided for @profileTargetWeight.
  ///
  /// In zh, this message translates to:
  /// **'目标体重: {weight}kg'**
  String profileTargetWeight(double weight);

  /// No description provided for @profileTargetBodyFat.
  ///
  /// In zh, this message translates to:
  /// **'目标体脂率: {fat}%'**
  String profileTargetBodyFat(double fat);

  /// No description provided for @profileLikes.
  ///
  /// In zh, this message translates to:
  /// **'爱吃: {foods}'**
  String profileLikes(String foods);

  /// No description provided for @profileDislikes.
  ///
  /// In zh, this message translates to:
  /// **'讨厌: {foods}'**
  String profileDislikes(String foods);

  /// No description provided for @editProfile.
  ///
  /// In zh, this message translates to:
  /// **'修改个人信息'**
  String get editProfile;

  /// No description provided for @aiConfigTitle.
  ///
  /// In zh, this message translates to:
  /// **'AI 配置'**
  String get aiConfigTitle;

  /// No description provided for @apiSettings.
  ///
  /// In zh, this message translates to:
  /// **'API 设置'**
  String get apiSettings;

  /// No description provided for @apiKey.
  ///
  /// In zh, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @modelName.
  ///
  /// In zh, this message translates to:
  /// **'模型名称'**
  String get modelName;

  /// No description provided for @baseUrlLabel.
  ///
  /// In zh, this message translates to:
  /// **'AI 服务商 (Base URL)'**
  String get baseUrlLabel;

  /// No description provided for @apiKeyTutorial.
  ///
  /// In zh, this message translates to:
  /// **'获取 API Key 教程'**
  String get apiKeyTutorial;

  /// No description provided for @apiKeyTutorialToast.
  ///
  /// In zh, this message translates to:
  /// **'获取 API Key 教程（待补充）'**
  String get apiKeyTutorialToast;

  /// No description provided for @saveConfig.
  ///
  /// In zh, this message translates to:
  /// **'保存配置'**
  String get saveConfig;

  /// No description provided for @customUrl.
  ///
  /// In zh, this message translates to:
  /// **'自定义 URL…'**
  String get customUrl;

  /// No description provided for @customBaseUrl.
  ///
  /// In zh, this message translates to:
  /// **'自定义 Base URL'**
  String get customBaseUrl;

  /// No description provided for @baseUrlHelper.
  ///
  /// In zh, this message translates to:
  /// **'自动补 /chat/completions'**
  String get baseUrlHelper;

  /// No description provided for @aiConfigSaved.
  ///
  /// In zh, this message translates to:
  /// **'AI 配置已保存'**
  String get aiConfigSaved;

  /// No description provided for @presetDeepSeek.
  ///
  /// In zh, this message translates to:
  /// **'DeepSeek'**
  String get presetDeepSeek;

  /// No description provided for @presetOpenAI.
  ///
  /// In zh, this message translates to:
  /// **'OpenAI'**
  String get presetOpenAI;

  /// No description provided for @presetMoonshot.
  ///
  /// In zh, this message translates to:
  /// **'Moonshot'**
  String get presetMoonshot;

  /// No description provided for @presetQwen.
  ///
  /// In zh, this message translates to:
  /// **'通义千问'**
  String get presetQwen;

  /// No description provided for @presetZhipu.
  ///
  /// In zh, this message translates to:
  /// **'智谱 GLM'**
  String get presetZhipu;

  /// No description provided for @presetSiliconFlow.
  ///
  /// In zh, this message translates to:
  /// **'SiliconFlow'**
  String get presetSiliconFlow;

  /// No description provided for @historyManagement.
  ///
  /// In zh, this message translates to:
  /// **'历史菜谱管理'**
  String get historyManagement;

  /// No description provided for @historyClearSummary.
  ///
  /// In zh, this message translates to:
  /// **'清除指定时间前的菜谱'**
  String get historyClearSummary;

  /// No description provided for @historyClearHelper.
  ///
  /// In zh, this message translates to:
  /// **'可选择日期，清除该日期之前的所有记录'**
  String get historyClearHelper;

  /// No description provided for @historyClearConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认清除'**
  String get historyClearConfirmTitle;

  /// No description provided for @historyClearConfirmBody.
  ///
  /// In zh, this message translates to:
  /// **'确定清除 {date} 之前的所有菜谱记录吗？'**
  String historyClearConfirmBody(String date);

  /// No description provided for @historyCleared.
  ///
  /// In zh, this message translates to:
  /// **'历史菜谱已清除'**
  String get historyCleared;

  /// No description provided for @historyNoRecords.
  ///
  /// In zh, this message translates to:
  /// **'暂无烹饪记录。点「已完成今天的烹饪」后会显示在这里。'**
  String get historyNoRecords;

  /// No description provided for @favoritesTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的收藏'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有收藏的菜谱'**
  String get favoritesEmpty;

  /// No description provided for @nudgeKitchenTitle.
  ///
  /// In zh, this message translates to:
  /// **'填写厨房信息'**
  String get nudgeKitchenTitle;

  /// No description provided for @nudgeKitchenBody.
  ///
  /// In zh, this message translates to:
  /// **'身体信息已填写。请前往【厨房】填写你的厨具和调味料信息。'**
  String get nudgeKitchenBody;

  /// No description provided for @nudgeGoKitchen.
  ///
  /// In zh, this message translates to:
  /// **'去填写'**
  String get nudgeGoKitchen;

  /// No description provided for @nudgeLater.
  ///
  /// In zh, this message translates to:
  /// **'稍后再说'**
  String get nudgeLater;

  /// No description provided for @nudgeAiTitle.
  ///
  /// In zh, this message translates to:
  /// **'配置 AI 服务'**
  String get nudgeAiTitle;

  /// No description provided for @nudgeAiBody.
  ///
  /// In zh, this message translates to:
  /// **'厨房信息已填写。请在【设置】中填写 AI Base URL 和 API Key，以便为你生成菜谱。'**
  String get nudgeAiBody;

  /// No description provided for @nudgeGoSettings.
  ///
  /// In zh, this message translates to:
  /// **'去设置'**
  String get nudgeGoSettings;

  /// No description provided for @languageTitle.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get languageTitle;

  /// No description provided for @chinese.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @languageChangedToast.
  ///
  /// In zh, this message translates to:
  /// **'已切换语言并清空相关数据'**
  String get languageChangedToast;

  /// No description provided for @languageUsageNote.
  ///
  /// In zh, this message translates to:
  /// **'切换语言会清空现有菜谱、冰箱与调味料数据'**
  String get languageUsageNote;

  /// No description provided for @onboardingAppBar.
  ///
  /// In zh, this message translates to:
  /// **'欢迎使用 肥鱼大厨'**
  String get onboardingAppBar;

  /// No description provided for @onboardingNext.
  ///
  /// In zh, this message translates to:
  /// **'下一步'**
  String get onboardingNext;

  /// No description provided for @onboardingDone.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get onboardingDone;

  /// No description provided for @onboardingProgress.
  ///
  /// In zh, this message translates to:
  /// **'{current} / {total}'**
  String onboardingProgress(int current, int total);

  /// No description provided for @welcomeTitle.
  ///
  /// In zh, this message translates to:
  /// **'欢迎来到 肥鱼大厨！'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'让我先了解你的身体状况和饮食偏好，\n我会为你规划健康又美味的一周菜谱。'**
  String get welcomeSubtitle;

  /// No description provided for @basicInfoTitle.
  ///
  /// In zh, this message translates to:
  /// **'基本信息'**
  String get basicInfoTitle;

  /// No description provided for @age.
  ///
  /// In zh, this message translates to:
  /// **'年龄'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get gender;

  /// No description provided for @genderMale.
  ///
  /// In zh, this message translates to:
  /// **'男'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In zh, this message translates to:
  /// **'女'**
  String get genderFemale;

  /// No description provided for @heightCm.
  ///
  /// In zh, this message translates to:
  /// **'身高 (cm)'**
  String get heightCm;

  /// No description provided for @weightKg.
  ///
  /// In zh, this message translates to:
  /// **'体重 (kg)'**
  String get weightKg;

  /// No description provided for @optionalInfoTitle.
  ///
  /// In zh, this message translates to:
  /// **'补充信息（选填）'**
  String get optionalInfoTitle;

  /// No description provided for @bodyFatPercent.
  ///
  /// In zh, this message translates to:
  /// **'体脂率 %（选填）'**
  String get bodyFatPercent;

  /// No description provided for @bodyFatHelper.
  ///
  /// In zh, this message translates to:
  /// **'不知道可以不填'**
  String get bodyFatHelper;

  /// No description provided for @healthNotes.
  ///
  /// In zh, this message translates to:
  /// **'体检报告异常项（选填）'**
  String get healthNotes;

  /// No description provided for @chronicDiseases.
  ///
  /// In zh, this message translates to:
  /// **'慢性病（选填）'**
  String get chronicDiseases;

  /// No description provided for @allergens.
  ///
  /// In zh, this message translates to:
  /// **'过敏的食物'**
  String get allergens;

  /// No description provided for @goalsTitle.
  ///
  /// In zh, this message translates to:
  /// **'目标设定'**
  String get goalsTitle;

  /// No description provided for @targetWeightKg.
  ///
  /// In zh, this message translates to:
  /// **'目标体重 (kg)'**
  String get targetWeightKg;

  /// No description provided for @targetBodyFatPercent.
  ///
  /// In zh, this message translates to:
  /// **'目标体脂率 %'**
  String get targetBodyFatPercent;

  /// No description provided for @foodPrefsTitle.
  ///
  /// In zh, this message translates to:
  /// **'食物偏好'**
  String get foodPrefsTitle;

  /// No description provided for @likedFoods.
  ///
  /// In zh, this message translates to:
  /// **'爱吃的食物'**
  String get likedFoods;

  /// No description provided for @dislikedFoods.
  ///
  /// In zh, this message translates to:
  /// **'讨厌的食物'**
  String get dislikedFoods;

  /// No description provided for @generateFailed.
  ///
  /// In zh, this message translates to:
  /// **'生成失败'**
  String get generateFailed;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @generating.
  ///
  /// In zh, this message translates to:
  /// **'正在为您规划菜谱...'**
  String get generating;

  /// No description provided for @generatingWait.
  ///
  /// In zh, this message translates to:
  /// **'肥鱼正在努力分析，会在90%处停留一段时间，请主人耐心等待，喵～'**
  String get generatingWait;

  /// No description provided for @progressPercent.
  ///
  /// In zh, this message translates to:
  /// **'{p}%'**
  String progressPercent(int p);

  /// No description provided for @errorMissingProfile.
  ///
  /// In zh, this message translates to:
  /// **'请先完成个人资料设置'**
  String get errorMissingProfile;

  /// No description provided for @errorMissingWeekPlan.
  ///
  /// In zh, this message translates to:
  /// **'返回数据格式错误：缺少 week_plan'**
  String get errorMissingWeekPlan;

  /// No description provided for @errorBaseUrlMissing.
  ///
  /// In zh, this message translates to:
  /// **'请先在设置中配置 API 地址 (Base URL)'**
  String get errorBaseUrlMissing;

  /// No description provided for @errorApiStatus.
  ///
  /// In zh, this message translates to:
  /// **'API 返回错误: {code}'**
  String errorApiStatus(int code);

  /// No description provided for @errorApiEmpty.
  ///
  /// In zh, this message translates to:
  /// **'API 返回为空'**
  String get errorApiEmpty;

  /// No description provided for @errorJsonParse.
  ///
  /// In zh, this message translates to:
  /// **'JSON 解析失败: {error}'**
  String errorJsonParse(String error);

  /// No description provided for @errorContentEmpty.
  ///
  /// In zh, this message translates to:
  /// **'API 返回内容为空'**
  String get errorContentEmpty;

  /// No description provided for @errorTimeout.
  ///
  /// In zh, this message translates to:
  /// **'网络超时，请检查网络连接'**
  String get errorTimeout;

  /// No description provided for @errorBadApiKey.
  ///
  /// In zh, this message translates to:
  /// **'API Key 无效，请在设置中检查'**
  String get errorBadApiKey;

  /// No description provided for @errorInsufficientBalance.
  ///
  /// In zh, this message translates to:
  /// **'API 余额不足，请充值'**
  String get errorInsufficientBalance;

  /// No description provided for @errorNetworkFailed.
  ///
  /// In zh, this message translates to:
  /// **'网络请求失败: {error}'**
  String errorNetworkFailed(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
