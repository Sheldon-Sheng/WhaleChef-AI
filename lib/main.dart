import 'package:flutter/material.dart';
import 'pages/home_page.dart';

/// App 入口
void main() {
  runApp(const DeepFryApp());
}

/// DeepFry — 跨平台双端 App 模板
///
/// 已集成：
/// - 暗色 / 亮色主题切换
/// - 首页功能卡片
/// - 设置页面
///
/// 你可以在此基础上添加自己的功能代码。
class DeepFryApp extends StatelessWidget {
  const DeepFryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepFry',
      debugShowCheckedModeBanner: false,
      // 默认主题（亮色），后续可在设置页切换
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, // 跟随系统
      home: const HomePage(),
    );
  }
}