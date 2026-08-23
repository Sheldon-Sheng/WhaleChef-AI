import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'data/local_db.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDB().init();
  runApp(const DeepFryApp());
}

class DeepFryApp extends StatelessWidget {
  const DeepFryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '肥鱼大厨',
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
      home: const SplashScreen(),
    );
  }
}