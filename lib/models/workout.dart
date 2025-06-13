enum MuscleGroup { chest, back, shoulders, arms, legs, core }

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
}

class MuscleRecoveryInfo {
  final MuscleGroup muscleGroup;
  final double damageLevel; // 0-10 scale
  final DateTime lastWorkoutDate;

  MuscleRecoveryInfo(this.muscleGroup, this.damageLevel, this.lastWorkoutDate);
}
