// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Whale Chef';

  @override
  String get tabRecipes => 'Recipes';

  @override
  String get tabFridge => 'Fridge';

  @override
  String get tabKitchen => 'Kitchen';

  @override
  String get tabStats => 'Stats';

  @override
  String get tabSettings => 'Settings';

  @override
  String get statsTitle => 'Weekly Calorie Stats';

  @override
  String get statsEmpty =>
      'No data yet. Complete a cooking day to see your stats.';

  @override
  String get statsCaloriesUnit => 'kcal';

  @override
  String get homeEmptyTitle => 'No meal plan yet';

  @override
  String get homeEmptySubtitle =>
      'Tell me your body info and dietary preferences,\nand I\'ll plan a healthy week of meals for you.';

  @override
  String get homeGeneratePlan => 'Generate Weekly Plan';

  @override
  String get homeStartSetup => 'Get Started';

  @override
  String get genDialogTitle => 'Meal Preferences';

  @override
  String get genDishesLabel => 'Dishes per meal';

  @override
  String genDishCount(int count) {
    return '$count dishes';
  }

  @override
  String get genMeatDishes => 'Meat dishes';

  @override
  String get genVeggieDishes => 'Veggie dishes';

  @override
  String get genAddSoup => 'Add soup';

  @override
  String get genCookTimeLabel => 'Cooking time limit (minutes)';

  @override
  String get genCuisineLabel => 'Cuisine style';

  @override
  String get cuisineChinese => 'Chinese';

  @override
  String get cuisineWestern => 'Western';

  @override
  String get cuisineJapanese => 'Japanese';

  @override
  String get genSelectMeals => 'Select meals to plan:';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get genPreferFavorites => 'Prioritize favorite recipes';

  @override
  String get genFavoriteCountLabel => 'Number of favorite recipes to use';

  @override
  String genFavoriteCountHelper(int max) {
    return 'Up to $max dishes ($max meals per week)';
  }

  @override
  String genFavoriteCountError(int max) {
    return 'Number cannot exceed $max';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get genConfirm => 'Generate Plan';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get todayRecipes => 'Today\'s Recipes';

  @override
  String dayRecipeTitle(String day) {
    return '$day recipes';
  }

  @override
  String get shoppingListName => 'Shopping List';

  @override
  String shoppingListTitle(int count) {
    return 'Shopping List ($count items to buy)';
  }

  @override
  String planTagDishes(int count) {
    return '$count dishes';
  }

  @override
  String get planTagSoup => 'with soup';

  @override
  String planTagMinutes(int min) {
    return '${min}min';
  }

  @override
  String get completeToday => 'Finished Today\'s Cooking';

  @override
  String get noRecipeToday => 'No recipes for today';

  @override
  String get confirmTitle => 'Confirm';

  @override
  String get confirmCookingBody =>
      'Finish today\'s cooking?\n\nIngredients for today will be deducted from the fridge, and the rest from the shopping list.';

  @override
  String get confirm => 'Confirm';

  @override
  String get doneCookingToast => 'Today\'s cooking completed!';

  @override
  String get kitchenTabTools => 'Utensils';

  @override
  String get kitchenTabSeasonings => 'Seasonings';

  @override
  String get toolInitTitle => 'Initialize Utensils';

  @override
  String get toolInitPrompt =>
      'We\'ve prepared a list of common kitchen utensils. Uncheck any you don\'t need:';

  @override
  String kitchenEmpty(String type) {
    return 'No $type yet. Tap + in the bottom-right to add.';
  }

  @override
  String get kitchenTypeTool => 'utensils';

  @override
  String get kitchenTypeSeasoning => 'seasonings';

  @override
  String get kitchenAvailable => 'Available';

  @override
  String get kitchenUnavailable => 'Unavailable';

  @override
  String kitchenAddDialogTitle(String type) {
    return 'Add $type';
  }

  @override
  String get kitchenName => 'Name';

  @override
  String get add => 'Add';

  @override
  String get seasoningInitTitle => 'Initialize Seasonings';

  @override
  String get seasoningInitPrompt =>
      'We\'ve prepared a list of common seasonings. Uncheck any you don\'t need:';

  @override
  String get seasoningSkip => 'Skip';

  @override
  String seasoningConfirmAdd(int count) {
    return 'Add Selected ($count)';
  }

  @override
  String get seasoningOutTitle => 'Out of Seasoning';

  @override
  String seasoningOutBody(String name) {
    return '$name is marked as unavailable and added to the shopping list.\nDo you want to replan the remaining recipes for this week?';
  }

  @override
  String get replan => 'Replan';

  @override
  String get later => 'Later';

  @override
  String get deleteConfirmTitle => 'Confirm Delete';

  @override
  String deleteConfirmBody(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get fridgeAddTitle => 'Add Ingredient';

  @override
  String get fridgeEditTitle => 'Edit Ingredient';

  @override
  String get fridgeName => 'Ingredient name';

  @override
  String get fridgeQty => 'Quantity (e.g. 500g, 3 pcs)';

  @override
  String get fridgeCategory => 'Category (optional)';

  @override
  String get save => 'Save';

  @override
  String get fridgeClearTitle => 'Clear Fridge';

  @override
  String get fridgeClearBody =>
      'Clear all ingredients from the fridge? This cannot be undone.';

  @override
  String get clear => 'Clear';

  @override
  String get fridgeEmpty =>
      'The fridge is empty. Tap + in the top-right to add ingredients.';

  @override
  String get fridgeUncategorized => 'Uncategorized';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get shoppingEmpty => 'Shopping list is empty';

  @override
  String get confirmPurchased => 'Mark as Purchased';

  @override
  String get purchaseSuccess => 'Purchased. Ingredients added to fridge.';

  @override
  String purchaseFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get cookingSteps => 'Cooking Steps';

  @override
  String get noSteps => 'No detailed steps';

  @override
  String get ingredientList => 'Ingredients';

  @override
  String get noIngredients => 'No ingredient info';

  @override
  String get seasonings => 'Seasonings';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileUnset => 'Not set';

  @override
  String profileAgeLabel(int age) {
    return 'Age: $age';
  }

  @override
  String profileHeightLabel(double height, double weight) {
    return 'Height: ${height}cm  Weight: ${weight}kg';
  }

  @override
  String profileTargetWeight(double weight) {
    return 'Target weight: ${weight}kg';
  }

  @override
  String profileTargetBodyFat(double fat) {
    return 'Target body fat: $fat%';
  }

  @override
  String profileLikes(String foods) {
    return 'Likes: $foods';
  }

  @override
  String profileDislikes(String foods) {
    return 'Dislikes: $foods';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get aiConfigTitle => 'AI Config';

  @override
  String get apiSettings => 'API Settings';

  @override
  String get apiKey => 'API Key';

  @override
  String get modelName => 'Model Name';

  @override
  String get baseUrlLabel => 'AI Provider (Base URL)';

  @override
  String get apiKeyTutorial => 'Get API Key Guide';

  @override
  String get apiKeyTutorialToast => 'Get API Key guide (coming soon)';

  @override
  String get saveConfig => 'Save Config';

  @override
  String get customUrl => 'Custom URL…';

  @override
  String get customBaseUrl => 'Custom Base URL';

  @override
  String get baseUrlHelper => 'Auto-appends /chat/completions';

  @override
  String get aiConfigSaved => 'AI config saved';

  @override
  String get presetDeepSeek => 'DeepSeek';

  @override
  String get presetOpenAI => 'OpenAI';

  @override
  String get presetMoonshot => 'Moonshot';

  @override
  String get presetQwen => 'Qwen';

  @override
  String get presetZhipu => 'Zhipu GLM';

  @override
  String get presetSiliconFlow => 'SiliconFlow';

  @override
  String get historyManagement => 'Recipe History';

  @override
  String get historyClearSummary => 'Clear recipes before a date';

  @override
  String get historyClearHelper => 'Pick a date to clear all records before it';

  @override
  String get historyClearConfirmTitle => 'Confirm Clear';

  @override
  String historyClearConfirmBody(String date) {
    return 'Clear all recipe records before $date?';
  }

  @override
  String get historyCleared => 'Recipe history cleared';

  @override
  String get historyNoRecords =>
      'No cooking records yet. Tap \"Finished Today\'s Cooking\" to add one.';

  @override
  String get favoritesTitle => 'My Favorites';

  @override
  String get favoritesEmpty => 'No favorite recipes yet';

  @override
  String get nudgeKitchenTitle => 'Set Up Kitchen';

  @override
  String get nudgeKitchenBody =>
      'Your body info is saved. Please add your kitchen utensils and seasonings in the Kitchen tab.';

  @override
  String get nudgeGoKitchen => 'Go to Kitchen';

  @override
  String get nudgeLater => 'Later';

  @override
  String get nudgeAiTitle => 'Configure AI';

  @override
  String get nudgeAiBody =>
      'Kitchen setup done. Please enter the AI Base URL and API Key in Settings so I can generate recipes.';

  @override
  String get nudgeGoSettings => 'Go to Settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get languageChangedToast =>
      'Language changed and related data cleared';

  @override
  String get languageUsageNote =>
      'Switching language clears your recipes, fridge and seasonings data';

  @override
  String get onboardingAppBar => 'Welcome to Whale Chef';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingDone => 'Done';

  @override
  String onboardingProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get welcomeTitle => 'Welcome to Whale Chef!';

  @override
  String get welcomeSubtitle =>
      'Let me learn about your body and dietary preferences,\nand I\'ll plan a healthy and delicious week of meals.';

  @override
  String get basicInfoTitle => 'Basic Info';

  @override
  String get age => 'Age';

  @override
  String get gender => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get optionalInfoTitle => 'Additional Info (optional)';

  @override
  String get bodyFatPercent => 'Body fat % (optional)';

  @override
  String get bodyFatHelper => 'Skip if you don\'t know';

  @override
  String get healthNotes => 'Health report issues (optional)';

  @override
  String get chronicDiseases => 'Chronic conditions (optional)';

  @override
  String get allergens => 'Allergens';

  @override
  String get goalsTitle => 'Goals';

  @override
  String get targetWeightKg => 'Target weight (kg)';

  @override
  String get targetBodyFatPercent => 'Target body fat %';

  @override
  String get foodPrefsTitle => 'Food Preferences';

  @override
  String get likedFoods => 'Foods you like';

  @override
  String get dislikedFoods => 'Foods you dislike';

  @override
  String get generateFailed => 'Generation Failed';

  @override
  String get retry => 'Retry';

  @override
  String get generating => 'Planning your recipes...';

  @override
  String get generatingWait =>
      'Whale is analyzing hard and will pause at 90% for a while. Please be patient, meow~';

  @override
  String progressPercent(int p) {
    return '$p%';
  }

  @override
  String get errorMissingProfile => 'Please complete your profile first';

  @override
  String get errorMissingWeekPlan => 'Invalid response: missing week_plan';

  @override
  String get errorBaseUrlMissing =>
      'Please configure the API Base URL in Settings first';

  @override
  String errorApiStatus(int code) {
    return 'API returned error: $code';
  }

  @override
  String get errorApiEmpty => 'Empty API response';

  @override
  String errorJsonParse(String error) {
    return 'Failed to parse JSON: $error';
  }

  @override
  String get errorContentEmpty => 'Empty API content';

  @override
  String get errorTimeout => 'Network timeout, please check your connection';

  @override
  String get errorBadApiKey => 'Invalid API Key, please check in Settings';

  @override
  String get errorInsufficientBalance =>
      'Insufficient API balance, please top up';

  @override
  String errorNetworkFailed(String error) {
    return 'Network request failed: $error';
  }
}
