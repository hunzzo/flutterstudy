import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/workout.dart';

class WorkoutData extends ChangeNotifier {
  static const String _storageKey = 'workoutData';

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

  WorkoutData() {
    _loadData();
  }

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
    _saveData();
  }

  void deleteWorkout(DateTime day, int index) {
    final key = DateTime(day.year, day.month, day.day);
    _workoutData[key]?.removeAt(index);
    notifyListeners();
    _saveData();
  }

  WorkoutRecord? latestRecordForExercise(String exercise) {
    DateTime? latestDate;
    WorkoutRecord? latest;
    _workoutData.forEach((date, records) {
      for (final r in records) {
        if (r.exercise == exercise) {
          if (latestDate == null || date.isAfter(latestDate!)) {
            latestDate = date;
            latest = r;
          }
        }
      }
    });
    return latest;
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return;

    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    _workoutData.clear();
    jsonData.forEach((key, value) {
      final date = DateTime.parse(key);
      final List<dynamic> list = value as List<dynamic>;
      _workoutData[date] =
          list.map((e) => WorkoutRecord.fromJson(e as Map<String, dynamic>)).toList();
    });
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> jsonData = {};
    _workoutData.forEach((key, value) {
      jsonData[key.toIso8601String()] = value.map((e) => e.toJson()).toList();
    });
    await prefs.setString(_storageKey, jsonEncode(jsonData));
  }

  void addSet(DateTime day, int workoutIndex, SetEntry set) {
    final key = DateTime(day.year, day.month, day.day);
    final workout = _workoutData[key]?[workoutIndex];
    if (workout != null) {
      workout.setDetails.add(set);
      notifyListeners();
      _saveData();
    }
  }

  void toggleSetDone(DateTime day, int workoutIndex, int setIndex) {
    final key = DateTime(day.year, day.month, day.day);
    final workout = _workoutData[key]?[workoutIndex];
    if (workout != null && setIndex < workout.setDetails.length) {
      final current = workout.setDetails[setIndex];
      workout.setDetails[setIndex] = SetEntry(
        current.weight,
        current.reps,
        done: !current.done,
      );
      notifyListeners();
      _saveData();
    }
  }

  void updateSet(DateTime day, int workoutIndex, int setIndex,
      {double? weight, int? reps}) {
    final key = DateTime(day.year, day.month, day.day);
    final workout = _workoutData[key]?[workoutIndex];
    if (workout != null && setIndex < workout.setDetails.length) {
      final current = workout.setDetails[setIndex];
      workout.setDetails[setIndex] = SetEntry(
        weight ?? current.weight,
        reps ?? current.reps,
        done: current.done,
      );
      notifyListeners();
      _saveData();
    }
  }

  int exerciseCount(String exercise) {
    int count = 0;
    _workoutData.forEach((_, list) {
      for (final r in list) {
        if (r.exercise == exercise) count++;
      }
    });
    return count;
  }

  Map<DateTime, List<WorkoutRecord>> get allWorkoutData =>
      Map.unmodifiable(_workoutData);
}
