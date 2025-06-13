enum MuscleGroup { chest, back, shoulders, arms, legs, core }

extension MuscleGroupExtension on MuscleGroup {
  String get name => toString().split('.').last;

  static MuscleGroup fromName(String name) {
    return MuscleGroup.values
        .firstWhere((e) => e.name == name, orElse: () => MuscleGroup.chest);
  }
}

class WorkoutRecord {
  final String exercise;
  final String sets;
  final String details;
  final MuscleGroup muscleGroup;
  final int intensity; // 1-10 scale

  WorkoutRecord(
    this.exercise,
    this.sets,
    this.details,
    this.muscleGroup,
    this.intensity,
  );

  Map<String, dynamic> toJson() => {
        'exercise': exercise,
        'sets': sets,
        'details': details,
        'muscleGroup': muscleGroup.name,
        'intensity': intensity,
      };

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) {
    return WorkoutRecord(
      json['exercise'] as String,
      json['sets'] as String,
      json['details'] as String,
      MuscleGroupExtension.fromName(json['muscleGroup'] as String),
      json['intensity'] as int,
    );
  }
}

class MuscleRecoveryInfo {
  final MuscleGroup muscleGroup;
  final double damageLevel; // 0-10 scale
  final DateTime lastWorkoutDate;

  MuscleRecoveryInfo(this.muscleGroup, this.damageLevel, this.lastWorkoutDate);
}
