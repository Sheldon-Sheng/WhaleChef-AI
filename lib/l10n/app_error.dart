// lib/l10n/app_error.dart

/// 稳定的机器可读错误码;由服务层抛出,UI 层依据 [AppErrorCode] 本地化显示。
enum AppErrorCode {
  missingProfile,
  missingWeekPlan,
  baseUrlMissing,
  apiStatus,
  apiEmpty,
  jsonParse,
  contentEmpty,
  timeout,
  badApiKey,
  insufficientBalance,
  networkFailed,
}

/// 携带 [code] + 参数的可类型化异常;toString 仅作日志/兜底,不代表用户可见文案。
class AppError implements Exception {
  final AppErrorCode code;
  final Map<String, Object?> params;

  const AppError(this.code, [this.params = const {}]);

  @override
  String toString() => 'AppError(${code.name})';
}
