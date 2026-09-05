// lib/l10n/localized_error.dart
import 'app_error.dart';
import 'app_language.dart';
import 'app_localizations.dart';

/// 把 [AppError] 翻译成当前语言的用户可见文案(无 context)。
String localizeAppError(AppError e) {
  final l = lookupAppLocalizations(AppLanguage.current);
  return switch (e.code) {
    AppErrorCode.missingProfile => l.errorMissingProfile,
    AppErrorCode.missingWeekPlan => l.errorMissingWeekPlan,
    AppErrorCode.baseUrlMissing => l.errorBaseUrlMissing,
    AppErrorCode.apiStatus => l.errorApiStatus(_int(e.params['status'])),
    AppErrorCode.apiEmpty => l.errorApiEmpty,
    AppErrorCode.jsonParse => l.errorJsonParse(_str(e.params['error'])),
    AppErrorCode.contentEmpty => l.errorContentEmpty,
    AppErrorCode.timeout => l.errorTimeout,
    AppErrorCode.badApiKey => l.errorBadApiKey,
    AppErrorCode.insufficientBalance => l.errorInsufficientBalance,
    AppErrorCode.networkFailed => l.errorNetworkFailed(_str(e.params['error'])),
  };
}

int _int(Object? v) => (v as num?)?.toInt() ?? 0;
String _str(Object? v) => (v ?? '').toString();
