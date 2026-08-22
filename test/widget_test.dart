// 冒烟测试：启动屏应完整渲染欢迎图片

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deepfry/main.dart';

void main() {
  testWidgets('启动屏渲染欢迎图片冒烟测试', (WidgetTester tester) async {
    await tester.pumpWidget(const DeepFryApp());

    // 启动屏应展示 assets/images/welcome.png
    final welcomeImage = find.byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName == 'assets/images/welcome.png',
    );
    expect(welcomeImage, findsOneWidget);
  });
}
