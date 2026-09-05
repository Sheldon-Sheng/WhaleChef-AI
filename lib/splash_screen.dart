// lib/splash_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/user_provider.dart';
import 'data/local_db.dart';
import 'providers/fridge_provider.dart';
import 'providers/kitchen_provider.dart';
import 'providers/meal_plan_provider.dart';
import 'pages/home_page.dart';
import 'pages/fridge_page.dart';
import 'pages/kitchen_page.dart';
import 'pages/stats_page.dart';
import 'pages/settings_page.dart';
import 'pages/onboarding/onboarding_page.dart';
import 'theme.dart';
import 'l10n/locale_provider.dart';
import 'l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeOut;
  Timer? _navigateTimer;

  @override
  void initState() {
    super.initState();

    // 过渡动画控制器：2s 停留 + 0.5s 淡出
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeOut = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    // 2s 后启动淡出动画，淡出结束后跳转
    _navigateTimer = Timer(const Duration(seconds: 2), () {
      _animController.forward().then((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const _MainApp(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _navigateTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeOut,
      child: Scaffold(
        body: Center(
          child: Image.asset(
            'assets/images/welcome.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, _, __) => Container(
              color: kSeedBlue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant, size: 80, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).appTitle,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 开屏结束后进入的主应用（带淡入过渡）
class _MainApp extends StatelessWidget {
  const _MainApp();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        ChangeNotifierProvider(create: (_) => FridgeProvider()..loadItems()),
        ChangeNotifierProvider(create: (_) => KitchenProvider()..loadItems()),
        ChangeNotifierProvider(
          create: (_) => MealPlanProvider()..loadActivePlan(),
        ),
        ChangeNotifierProvider.value(value: LocaleProvider.instance),
      ],
      child: ListenableBuilder(
        listenable: LocaleProvider.instance,
        builder: (context, _) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: kSeedBlue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: kSeedBlue,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: ThemeMode.system,
            locale: LocaleProvider.instance.locale,
            supportedLocales: const [Locale('zh'), Locale('en')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: {
              '/': (context) {
                final userProvider = context.watch<UserProvider>();
                if (!userProvider.hasCompletedOnboarding) {
                  return const OnboardingPage();
                }
                return const MainShell();
              },
              '/onboarding': (context) => const OnboardingPage(),
              '/home': (context) => const MainShell(),
            },
          );
        },
      ),
    );
  }
}

/// 主页面 Shell（底部 4 Tab）
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _kitchenNudgeDone = false;
  bool _aiNudgeDone = false;
  bool _nudgeBusy = false;
  KitchenProvider? _kitchenProviderRef;
  static const _pages = [
    HomePage(),
    FridgePage(),
    KitchenPage(),
    StatsPage(),
    SettingsPage(),
  ];

  static const _kKitchenNudge = 'nudge_kitchen_done';
  static const _kAiNudge = 'nudge_ai_done';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initNudges());
  }

  @override
  void dispose() {
    _kitchenProviderRef?.removeListener(_onProviderChanged);
    super.dispose();
  }

  // === 首次引导：身体信息 → 厨房(厨具/调味料) → AI 配置 ===

  Future<void> _initNudges() async {
    final p = await SharedPreferences.getInstance();
    _kitchenNudgeDone = p.getBool(_kKitchenNudge) ?? false;
    _aiNudgeDone = p.getBool(_kAiNudge) ?? false;
    final kitchen = context.read<KitchenProvider>();
    _kitchenProviderRef = kitchen;
    kitchen.addListener(_onProviderChanged);
    await _maybeShowNudge();
  }

  void _onProviderChanged() {
    if (mounted) _maybeShowNudge();
  }

  Future<void> _maybeShowNudge() async {
    if (_nudgeBusy || !mounted) return;
    final kitchen = context.read<KitchenProvider>();
    final user = context.read<UserProvider>();
    if (user.userProfile == null) return; // 尚未完成 onboarding
    final kitchenEmpty = kitchen.tools.isEmpty && kitchen.seasonings.isEmpty;

    if (!_kitchenNudgeDone && kitchenEmpty) {
      await _showKitchenNudge();
    } else if (!_aiNudgeDone) {
      await _showAiNudge();
    }
  }

  Future<void> _showKitchenNudge() async {
    final l10n = AppLocalizations.of(context);
    _nudgeBusy = true;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.nudgeKitchenTitle),
        content: Text(l10n.nudgeKitchenBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.nudgeLater),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.nudgeGoKitchen),
          ),
        ],
      ),
    );
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kKitchenNudge, true);
    _kitchenNudgeDone = true;
    _nudgeBusy = false;
    // 用户选择「去填写」，切到厨房标签
    if (go == true && mounted) {
      setState(() => _currentIndex = 2);
    }
  }

  Future<void> _showAiNudge() async {
    final l10n = AppLocalizations.of(context);
    _nudgeBusy = true;
    final config = await LocalDB().getAIConfig();
    final configured =
        (config['base_url'] ?? '').toString().trim().isNotEmpty &&
        (config['api_key'] ?? '').toString().trim().isNotEmpty;
    if (configured) {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kAiNudge, true);
      _aiNudgeDone = true;
      _nudgeBusy = false;
      return;
    }
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.nudgeAiTitle),
        content: Text(l10n.nudgeAiBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.nudgeLater),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.nudgeGoSettings),
          ),
        ],
      ),
    );
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kAiNudge, true);
    _aiNudgeDone = true;
    _nudgeBusy = false;
    // 用户选择「去设置」，切到设置标签
    if (go == true && mounted) {
      setState(() => _currentIndex = 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu),
            label: l10n.tabRecipes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.kitchen),
            label: l10n.tabFridge,
          ),
          NavigationDestination(
            icon: const Icon(Icons.countertops),
            label: l10n.tabKitchen,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart),
            label: l10n.tabStats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l10n.tabSettings,
          ),
        ],
      ),
    );
  }
}
