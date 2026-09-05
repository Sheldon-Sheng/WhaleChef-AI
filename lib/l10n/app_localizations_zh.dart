// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '肥鱼大厨';

  @override
  String get tabRecipes => '菜谱';

  @override
  String get tabFridge => '冰箱';

  @override
  String get tabKitchen => '厨房';

  @override
  String get tabStats => '统计';

  @override
  String get tabSettings => '设置';

  @override
  String get statsTitle => '每周卡路里统计';

  @override
  String get statsEmpty => '暂无数据，完成一次烹饪后在这里查看统计。';

  @override
  String get statsCaloriesUnit => '千卡';

  @override
  String get homeEmptyTitle => '还没有菜谱计划';

  @override
  String get homeEmptySubtitle => '告诉我你的身体数据和饮食偏好，\n我来为你定制一周健康菜谱。';

  @override
  String get homeGeneratePlan => '生成一周菜谱';

  @override
  String get homeStartSetup => '开始设置';

  @override
  String get genDialogTitle => '菜谱要求';

  @override
  String get genDishesLabel => '几道菜';

  @override
  String genDishCount(int count) {
    return '$count 道';
  }

  @override
  String get genMeatDishes => '荤菜';

  @override
  String get genVeggieDishes => '素菜';

  @override
  String get genAddSoup => '加汤';

  @override
  String get genCookTimeLabel => '烹饪时间限制（分钟）';

  @override
  String get genCuisineLabel => '菜品风格';

  @override
  String get cuisineChinese => '中餐';

  @override
  String get cuisineWestern => '西餐';

  @override
  String get cuisineJapanese => '日式';

  @override
  String get genSelectMeals => '请选择需要规划的餐次：';

  @override
  String get mealBreakfast => '早餐';

  @override
  String get mealLunch => '午餐';

  @override
  String get mealDinner => '晚餐';

  @override
  String get genPreferFavorites => '优先在收藏菜谱中选择';

  @override
  String get genFavoriteCountLabel => '优先使用收藏菜谱数量';

  @override
  String genFavoriteCountHelper(int max) {
    return '最多 $max 道（一周共 $max 餐）';
  }

  @override
  String genFavoriteCountError(int max) {
    return '数字不能超过 $max';
  }

  @override
  String get cancel => '取消';

  @override
  String get genConfirm => '生成菜谱';

  @override
  String get weekdayMon => '周一';

  @override
  String get weekdayTue => '周二';

  @override
  String get weekdayWed => '周三';

  @override
  String get weekdayThu => '周四';

  @override
  String get weekdayFri => '周五';

  @override
  String get weekdaySat => '周六';

  @override
  String get weekdaySun => '周日';

  @override
  String get todayRecipes => '今日菜谱';

  @override
  String dayRecipeTitle(String day) {
    return '$day菜谱';
  }

  @override
  String get shoppingListName => '食材采购清单';

  @override
  String shoppingListTitle(int count) {
    return '食材采购清单（$count 项待购）';
  }

  @override
  String planTagDishes(int count) {
    return '$count 道菜';
  }

  @override
  String get planTagSoup => '加汤';

  @override
  String planTagMinutes(int min) {
    return '${min}min';
  }

  @override
  String get completeToday => '已完成今天的烹饪';

  @override
  String get noRecipeToday => '今日没有菜谱';

  @override
  String get confirmTitle => '确认完成';

  @override
  String get confirmCookingBody => '确认完成今日烹饪吗？\n\n将从冰箱扣除今日所需食材，不足部分从采购清单中扣除。';

  @override
  String get confirm => '确认';

  @override
  String get doneCookingToast => '已完成今日烹饪！';

  @override
  String get kitchenTabTools => '厨具';

  @override
  String get kitchenTabSeasonings => '调味料';

  @override
  String get toolInitTitle => '初始化厨具';

  @override
  String get toolInitPrompt => '已为您准备了常用厨具列表，请取消勾选您不需要的厨具：';

  @override
  String kitchenEmpty(String type) {
    return '还没有$type，点击右下角 + 添加';
  }

  @override
  String get kitchenTypeTool => '厨具';

  @override
  String get kitchenTypeSeasoning => '调味料';

  @override
  String get kitchenAvailable => '有';

  @override
  String get kitchenUnavailable => '无';

  @override
  String kitchenAddDialogTitle(String type) {
    return '添加$type';
  }

  @override
  String get kitchenName => '名称';

  @override
  String get add => '添加';

  @override
  String get seasoningInitTitle => '初始化调味料';

  @override
  String get seasoningInitPrompt => '已为您准备了常用调味料列表，请取消勾选您不需要的调味料：';

  @override
  String get seasoningSkip => '跳过';

  @override
  String seasoningConfirmAdd(int count) {
    return '确认添加（$count 项）';
  }

  @override
  String get seasoningOutTitle => '调味料用完';

  @override
  String seasoningOutBody(String name) {
    return '$name已标记为\"无\"，并已加入采购清单。\n是否需要根据缺少调味料的情况重新规划本周剩余菜谱？';
  }

  @override
  String get replan => '重新规划';

  @override
  String get later => '稍后再说';

  @override
  String get deleteConfirmTitle => '确认删除';

  @override
  String deleteConfirmBody(String name) {
    return '确定删除「$name」吗？';
  }

  @override
  String get delete => '删除';

  @override
  String get fridgeAddTitle => '添加食材';

  @override
  String get fridgeEditTitle => '编辑食材';

  @override
  String get fridgeName => '食材名';

  @override
  String get fridgeQty => '数量（如: 500g、3个）';

  @override
  String get fridgeCategory => '分类（可选）';

  @override
  String get save => '保存';

  @override
  String get fridgeClearTitle => '清空冰箱';

  @override
  String get fridgeClearBody => '确定要清空冰箱中所有食材吗？此操作不可撤销。';

  @override
  String get clear => '清空';

  @override
  String get fridgeEmpty => '冰箱是空的，点击右上角 + 添加食材';

  @override
  String get fridgeUncategorized => '未分类';

  @override
  String get selectAll => '全选';

  @override
  String get deselectAll => '取消全选';

  @override
  String selectedCount(int count) {
    return '$count 项已选';
  }

  @override
  String get shoppingEmpty => '采购清单为空';

  @override
  String get confirmPurchased => '确认已购买';

  @override
  String get purchaseSuccess => '已确认购买，食材已加入冰箱';

  @override
  String purchaseFailed(String error) {
    return '操作失败: $error';
  }

  @override
  String get cookingSteps => '烹饪步骤';

  @override
  String get noSteps => '暂无详细步骤';

  @override
  String get ingredientList => '食材清单';

  @override
  String get noIngredients => '无食材信息';

  @override
  String get seasonings => '调味品';

  @override
  String get profileTitle => '个人信息';

  @override
  String get profileUnset => '未设置';

  @override
  String profileAgeLabel(int age) {
    return '年龄: $age';
  }

  @override
  String profileHeightLabel(double height, double weight) {
    return '身高: ${height}cm 体重: ${weight}kg';
  }

  @override
  String profileTargetWeight(double weight) {
    return '目标体重: ${weight}kg';
  }

  @override
  String profileTargetBodyFat(double fat) {
    return '目标体脂率: $fat%';
  }

  @override
  String profileLikes(String foods) {
    return '爱吃: $foods';
  }

  @override
  String profileDislikes(String foods) {
    return '讨厌: $foods';
  }

  @override
  String get editProfile => '修改个人信息';

  @override
  String get aiConfigTitle => 'AI 配置';

  @override
  String get apiSettings => 'API 设置';

  @override
  String get apiKey => 'API Key';

  @override
  String get modelName => '模型名称';

  @override
  String get baseUrlLabel => 'AI 服务商 (Base URL)';

  @override
  String get apiKeyTutorial => '获取 API Key 教程';

  @override
  String get apiKeyTutorialToast => '获取 API Key 教程（待补充）';

  @override
  String get saveConfig => '保存配置';

  @override
  String get customUrl => '自定义 URL…';

  @override
  String get customBaseUrl => '自定义 Base URL';

  @override
  String get baseUrlHelper => '自动补 /chat/completions';

  @override
  String get aiConfigSaved => 'AI 配置已保存';

  @override
  String get presetDeepSeek => 'DeepSeek';

  @override
  String get presetOpenAI => 'OpenAI';

  @override
  String get presetMoonshot => 'Moonshot';

  @override
  String get presetQwen => '通义千问';

  @override
  String get presetZhipu => '智谱 GLM';

  @override
  String get presetSiliconFlow => 'SiliconFlow';

  @override
  String get historyManagement => '历史菜谱管理';

  @override
  String get historyClearSummary => '清除指定时间前的菜谱';

  @override
  String get historyClearHelper => '可选择日期，清除该日期之前的所有记录';

  @override
  String get historyClearConfirmTitle => '确认清除';

  @override
  String historyClearConfirmBody(String date) {
    return '确定清除 $date 之前的所有菜谱记录吗？';
  }

  @override
  String get historyCleared => '历史菜谱已清除';

  @override
  String get historyNoRecords => '暂无烹饪记录。点「已完成今天的烹饪」后会显示在这里。';

  @override
  String get favoritesTitle => '我的收藏';

  @override
  String get favoritesEmpty => '还没有收藏的菜谱';

  @override
  String get nudgeKitchenTitle => '填写厨房信息';

  @override
  String get nudgeKitchenBody => '身体信息已填写。请前往【厨房】填写你的厨具和调味料信息。';

  @override
  String get nudgeGoKitchen => '去填写';

  @override
  String get nudgeLater => '稍后再说';

  @override
  String get nudgeAiTitle => '配置 AI 服务';

  @override
  String get nudgeAiBody => '厨房信息已填写。请在【设置】中填写 AI Base URL 和 API Key，以便为你生成菜谱。';

  @override
  String get nudgeGoSettings => '去设置';

  @override
  String get languageTitle => '语言';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get languageChangedToast => '已切换语言并清空相关数据';

  @override
  String get languageUsageNote => '切换语言会清空现有菜谱、冰箱与调味料数据';

  @override
  String get onboardingAppBar => '欢迎使用 肥鱼大厨';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingDone => '完成';

  @override
  String onboardingProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get welcomeTitle => '欢迎来到 肥鱼大厨！';

  @override
  String get welcomeSubtitle => '让我先了解你的身体状况和饮食偏好，\n我会为你规划健康又美味的一周菜谱。';

  @override
  String get basicInfoTitle => '基本信息';

  @override
  String get age => '年龄';

  @override
  String get gender => '性别';

  @override
  String get genderMale => '男';

  @override
  String get genderFemale => '女';

  @override
  String get heightCm => '身高 (cm)';

  @override
  String get weightKg => '体重 (kg)';

  @override
  String get optionalInfoTitle => '补充信息（选填）';

  @override
  String get bodyFatPercent => '体脂率 %（选填）';

  @override
  String get bodyFatHelper => '不知道可以不填';

  @override
  String get healthNotes => '体检报告异常项（选填）';

  @override
  String get chronicDiseases => '慢性病（选填）';

  @override
  String get allergens => '过敏的食物';

  @override
  String get goalsTitle => '目标设定';

  @override
  String get targetWeightKg => '目标体重 (kg)';

  @override
  String get targetBodyFatPercent => '目标体脂率 %';

  @override
  String get foodPrefsTitle => '食物偏好';

  @override
  String get likedFoods => '爱吃的食物';

  @override
  String get dislikedFoods => '讨厌的食物';

  @override
  String get generateFailed => '生成失败';

  @override
  String get retry => '重试';

  @override
  String get generating => '正在为您规划菜谱...';

  @override
  String get generatingWait => '肥鱼正在努力分析，会在90%处停留一段时间，请主人耐心等待，喵～';

  @override
  String progressPercent(int p) {
    return '$p%';
  }

  @override
  String get errorMissingProfile => '请先完成个人资料设置';

  @override
  String get errorMissingWeekPlan => '返回数据格式错误：缺少 week_plan';

  @override
  String get errorBaseUrlMissing => '请先在设置中配置 API 地址 (Base URL)';

  @override
  String errorApiStatus(int code) {
    return 'API 返回错误: $code';
  }

  @override
  String get errorApiEmpty => 'API 返回为空';

  @override
  String errorJsonParse(String error) {
    return 'JSON 解析失败: $error';
  }

  @override
  String get errorContentEmpty => 'API 返回内容为空';

  @override
  String get errorTimeout => '网络超时，请检查网络连接';

  @override
  String get errorBadApiKey => 'API Key 无效，请在设置中检查';

  @override
  String get errorInsufficientBalance => 'API 余额不足，请充值';

  @override
  String errorNetworkFailed(String error) {
    return '网络请求失败: $error';
  }
}
