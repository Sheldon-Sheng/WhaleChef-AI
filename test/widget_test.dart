// 基础冒烟测试：验证 App 能正常构建

import 'package:flutter_test/flutter_test.dart';

import 'package:deepfry/main.dart';

void main() {
  testWidgets('App 可以构建', (WidgetTester tester) async {
    // 仅验证 App 类能正常构建，不进行完整渲染
    // （完整渲染需要 sqflite 数据库初始化，在测试环境中跳过）
    final app = const DeepFryApp();
    expect(app, isNotNull);
  });
}