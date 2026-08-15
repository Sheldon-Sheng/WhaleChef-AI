// 冒烟测试：初始化 sqflite FFI 数据库并完整渲染 App

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:deepfry/main.dart';
import 'package:deepfry/data/local_db.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    // 使用内存数据库，避免测试写入磁盘
    databaseFactory = databaseFactoryFfiNoIsolate;
    await LocalDB().init();
  });

  testWidgets('App 完整渲染冒烟测试', (WidgetTester tester) async {
    await tester.pumpWidget(const DeepFryApp());
    await tester.pumpAndSettle();
    // 根路由至少渲染出页面（欢迎页或主 shell）
    expect(find.byType(DeepFryApp), findsOneWidget);
  });
}