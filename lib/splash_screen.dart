// lib/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/fridge_provider.dart';
import 'providers/kitchen_provider.dart';
import 'providers/meal_plan_provider.dart';
import 'pages/home_page.dart';
import 'pages/fridge_page.dart';
import 'pages/kitchen_page.dart';
import 'pages/settings_page.dart';
import 'pages/onboarding/onboarding_page.dart';
import 'theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
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
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

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
            errorBuilder: (_, __, ___) => Container(
              color: kSeedBlue,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 80, color: Colors.white),
                  SizedBox(height: 16),
                  Text('DeepFry', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
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
        ChangeNotifierProvider(create: (_) => MealPlanProvider()..loadActivePlan()),
      ],
      child: MaterialApp(
        title: 'DeepFry',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kSeedBlue, brightness: Brightness.light),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kSeedBlue, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
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
  final _pages = const [
    HomePage(),
    FridgePage(),
    KitchenPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: '菜谱'),
          NavigationDestination(icon: Icon(Icons.kitchen), label: '冰箱'),
          NavigationDestination(icon: Icon(Icons.countertops), label: '厨房'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}