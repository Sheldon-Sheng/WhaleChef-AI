// 数量格式化的语言感知测试（中文保持字节级不变，英文加空格/用 as needed）

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:deepfry/utils/quantity.dart';
import 'package:deepfry/l10n/locale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await LocaleProvider.instance.setLocale(const Locale('zh'));
  });

  test('formatQuantity 中文：无空格，"适量"', () {
    expect(formatQuantity(3, '个'), '3个');
    expect(formatQuantity(2, '个'), '2个');
    expect(formatQuantity(1.5, '个'), '1.5个');
    expect(formatQuantity(500, 'g'), '500g');
    expect(formatQuantity(0, ''), '适量');
    expect(formatQuantity(0, '适量'), '适量');
    expect(asNeededLabel, '适量');
  });

  test('formatQuantity 英文：加空格，"as needed"', () async {
    await LocaleProvider.instance.setLocale(const Locale('en'));
    expect(formatQuantity(3, 'pc'), '3 pc');
    expect(formatQuantity(2, '个'), '2 个');
    expect(formatQuantity(500, 'g'), '500 g');
    expect(formatQuantity(0, ''), 'as needed');
    expect(formatQuantity(0, 'as needed'), 'as needed');
    expect(asNeededLabel, 'as needed');
  });
}
