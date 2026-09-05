// lib/l10n/app_language.dart
import 'package:flutter/widgets.dart';

import 'locale_provider.dart';

/// 无 context 代码(服务层/纯工具函数)读取当前语言的轻量入口。
class AppLanguage {
  static bool get isEnglish => LocaleProvider.instance.isEnglish;
  static Locale get current => LocaleProvider.instance.locale;
}
