// lib/l10n/locale_provider.dart
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局语言状态(中文/英文),持久化到 SharedPreferences。
/// 通过 [instance] 以全局单例使用;同时可注入到 Provider 树供 context.read/watch。
class LocaleProvider extends ChangeNotifier {
  static final LocaleProvider instance = LocaleProvider._();
  LocaleProvider._();

  static const String _prefsKey = 'app_language';

  Locale _locale = const Locale('zh');

  Locale get locale => _locale;
  bool get isEnglish => _locale.languageCode == 'en';

  /// App 启动时读取语言偏好；若用户从未设置，则按系统语言推断默认语言
  /// （简体/繁体中文 → 中文；其他 → 英文）。
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      _locale = stored == 'en' ? const Locale('en') : const Locale('zh');
    } else {
      // 首次安装：根据手机系统语言决定默认语言
      final sysLang =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      _locale = sysLang.toLowerCase().startsWith('zh')
          ? const Locale('zh')
          : const Locale('en');
    }
    notifyListeners();
  }

  /// 切换语言并持久化
  Future<void> setLocale(Locale l) async {
    if (l == _locale) return;
    _locale = l;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, l.languageCode);
  }
}
