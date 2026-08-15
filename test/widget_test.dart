// 模板的基础冒烟测试：启动 App，验证首页能正常渲染。

import 'package:flutter_test/flutter_test.dart';

import 'package:deepfry/main.dart';

void main() {
  testWidgets('App 可以启动并显示首页', (WidgetTester tester) async {
    // 构建整个 App
    await tester.pumpWidget(const DeepFryApp());

    // 首页标题应存在
    expect(find.text('DeepFry'), findsOneWidget);

    // 计数器卡片应存在，初始为 0
    expect(find.textContaining('你按了 0 次'), findsOneWidget);

    // 点击 +1 按钮
    await tester.tap(find.text('+1'));
    await tester.pump();

    // 计数应变为 1
    expect(find.textContaining('你按了 1 次'), findsOneWidget);
  });
}