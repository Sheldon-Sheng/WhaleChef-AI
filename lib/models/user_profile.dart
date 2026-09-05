// lib/models/user_profile.dart
class UserProfile {
  final int? id;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final double? bodyFatRate;
  final String? healthReportNotes;
  final String? chronicDiseases;
  final double targetWeight;
  final double targetBodyFat;
  final String preferredFoods; // 逗号分隔
  final String dislikedFoods; // 逗号分隔
  final String allergens; // 逗号分隔，过敏的食物
  final int updatedAt;

  UserProfile({
    this.id,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    this.bodyFatRate,
    this.healthReportNotes,
    this.chronicDiseases,
    required this.targetWeight,
    required this.targetBodyFat,
    this.preferredFoods = '',
    this.dislikedFoods = '',
    this.allergens = '',
    int? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'age': age,
    'gender': gender,
    'height': height,
    'weight': weight,
    'body_fat_rate': bodyFatRate,
    'health_report_notes': healthReportNotes,
    'chronic_diseases': chronicDiseases,
    'target_weight': targetWeight,
    'target_body_fat': targetBodyFat,
    'preferred_foods': preferredFoods,
    'disliked_foods': dislikedFoods,
    'allergens': allergens,
    'updated_at': updatedAt,
  };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    id: map['id'] as int?,
    age: map['age'] as int,
    gender: map['gender'] as String,
    height: map['height'] as double,
    weight: map['weight'] as double,
    bodyFatRate: map['body_fat_rate'] as double?,
    healthReportNotes: map['health_report_notes'] as String?,
    chronicDiseases: map['chronic_diseases'] as String?,
    targetWeight: map['target_weight'] as double,
    targetBodyFat: map['target_body_fat'] as double,
    preferredFoods: map['preferred_foods'] as String? ?? '',
    dislikedFoods: map['disliked_foods'] as String? ?? '',
    allergens: map['allergens'] as String? ?? '',
    updatedAt: map['updated_at'] as int? ?? 0,
  );

  UserProfile copyWith({
    int? age,
    String? gender,
    double? height,
    double? weight,
    double? bodyFatRate,
    String? healthReportNotes,
    String? chronicDiseases,
    double? targetWeight,
    double? targetBodyFat,
    String? preferredFoods,
    String? dislikedFoods,
    String? allergens,
  }) => UserProfile(
    id: id,
    age: age ?? this.age,
    gender: gender ?? this.gender,
    height: height ?? this.height,
    weight: weight ?? this.weight,
    bodyFatRate: bodyFatRate ?? this.bodyFatRate,
    healthReportNotes: healthReportNotes ?? this.healthReportNotes,
    chronicDiseases: chronicDiseases ?? this.chronicDiseases,
    targetWeight: targetWeight ?? this.targetWeight,
    targetBodyFat: targetBodyFat ?? this.targetBodyFat,
    preferredFoods: preferredFoods ?? this.preferredFoods,
    dislikedFoods: dislikedFoods ?? this.dislikedFoods,
    allergens: allergens ?? this.allergens,
  );
}
