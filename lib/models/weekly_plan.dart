// lib/models/weekly_plan.dart
class WeeklyPlan {
  final int? id;
  final int weekStart; // 开始日期时间戳
  final String planConfig; // JSON 配置
  final String status; // 'active' / 'completed'
  final int createdAt;

  WeeklyPlan({
    this.id,
    required this.weekStart,
    this.planConfig = '{}',
    this.status = 'active',
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'week_start': weekStart,
    'plan_config': planConfig,
    'status': status,
    'created_at': createdAt,
  };

  factory WeeklyPlan.fromMap(Map<String, dynamic> map) => WeeklyPlan(
    id: map['id'] as int?,
    weekStart: map['week_start'] as int,
    planConfig: map['plan_config'] as String? ?? '{}',
    status: map['status'] as String? ?? 'active',
    createdAt: map['created_at'] as int? ?? 0,
  );
}