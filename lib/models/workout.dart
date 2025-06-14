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
  final List<SetEntry> setDetails;

  WorkoutRecord(
    this.exercise,
    this.sets,
    this.details,
    this.muscleGroup,
    this.intensity,
    [List<SetEntry>? setDetails]
  ) : setDetails = setDetails ?? [];

  Map<String, dynamic> toJson() => {
        'exercise': exercise,
        'sets': sets,
        'details': details,
        'muscleGroup': muscleGroup.name,
        'intensity': intensity,
        'setDetails': setDetails.map((e) => e.toJson()).toList(),
      };

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) {
    return WorkoutRecord(
      json['exercise'] as String,
      json['sets'] as String,
      json['details'] as String,
      MuscleGroupExtension.fromName(json['muscleGroup'] as String),
      json['intensity'] as int,
      (json['setDetails'] as List<dynamic>?)
              ?.map((e) => SetEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SetEntry {
  final double weight;
  final int reps;
  final bool done;

  SetEntry(this.weight, this.reps, {this.done = false});

  Map<String, dynamic> toJson() => {
        'w': weight,
        'r': reps,
        'd': done,
      };

  factory SetEntry.fromJson(Map<String, dynamic> json) {
    return SetEntry(
      (json['w'] as num).toDouble(),
      json['r'] as int,
      done: json['d'] as bool? ?? false,
    );
  }
}

class MuscleRecoveryInfo {
  final MuscleGroup muscleGroup;
  final double damageLevel; // 0-10 scale
  final DateTime lastWorkoutDate;

  MuscleRecoveryInfo(this.muscleGroup, this.damageLevel, this.lastWorkoutDate);
}
