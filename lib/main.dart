import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/local_db.dart';
import 'providers/user_provider.dart';
import 'providers/fridge_provider.dart';
import 'providers/kitchen_provider.dart';
import 'providers/meal_plan_provider.dart';
import 'pages/home_page.dart';
import 'pages/fridge_page.dart';
import 'pages/kitchen_page.dart';
import 'pages/settings_page.dart';
import 'pages/onboarding/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDB().init();
  runApp(const DeepFryApp());
}

class DeepFryApp extends StatelessWidget {
  const DeepFryApp({super.key});

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.light),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.dark),
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