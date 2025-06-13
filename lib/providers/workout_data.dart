import 'package:flutter/material.dart';

import '../models/workout.dart';

class WorkoutData extends ChangeNotifier {
  final Map<DateTime, List<WorkoutRecord>> _workoutData = {
    DateTime.now(): [
      WorkoutRecord('벤치프레스', '3세트', '80kg x 10회', MuscleGroup.chest, 8),
      WorkoutRecord('스쿼트', '4세트', '100kg x 8회', MuscleGroup.legs, 9),
      WorkoutRecord('데드리프트', '3세트', '120kg x 5회', MuscleGroup.back, 9),
    ],
    DateTime.now().subtract(Duration(days: 1)): [
      WorkoutRecord('풀업', '3세트', '체중 x 12회', MuscleGroup.back, 7),
      WorkoutRecord('딥스', '3세트', '체중 x 15회', MuscleGroup.chest, 6),
      WorkoutRecord('어깨 프레스', '4세트', '40kg x 12회', MuscleGroup.shoulders, 8),
    ],
    DateTime.now().subtract(Duration(days: 2)): [
      WorkoutRecord('바이셉 컬', '3세트', '15kg x 15회', MuscleGroup.arms, 6),
      WorkoutRecord('트라이셉 딥', '3세트', '체중 x 12회', MuscleGroup.arms, 7),
      WorkoutRecord('레그 프레스', '4세트', '150kg x 12회', MuscleGroup.legs, 8),
    ],
  };

  List<WorkoutRecord> workoutsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _workoutData[key] ?? [];
  }

  void addWorkout(DateTime day, WorkoutRecord record) {
    final key = DateTime(day.year, day.month, day.day);
    if (_workoutData[key] == null) {
      _workoutData[key] = [];
    }
    _workoutData[key]!.add(record);
    notifyListeners();
  }

  void deleteWorkout(DateTime day, int index) {
    final key = DateTime(day.year, day.month, day.day);
    _workoutData[key]?.removeAt(index);
    notifyListeners();
  }
}
