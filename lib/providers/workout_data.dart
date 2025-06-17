import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/workout.dart';

class WorkoutData extends ChangeNotifier {
  static const String _storageKey = 'workoutData';

  final Map<DateTime, List<WorkoutRecord>> _workoutData = {};

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
      final parsed = DateTime.parse(key);
      final date = DateTime(parsed.year, parsed.month, parsed.day);
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

  void addSet(DateTime day, int workoutIndex) {
    final key = DateTime(day.year, day.month, day.day);
    final workout = _workoutData[key]?[workoutIndex];
    if (workout != null) {
      double weight = 0;
      int reps = 0;
      if (workout.setDetails.isNotEmpty) {
        weight = workout.setDetails.last.weight;
        reps = workout.setDetails.last.reps;
      } else {
        final latest = latestRecordForExercise(workout.exercise);
        if (latest != null && latest.setDetails.isNotEmpty) {
          weight = latest.setDetails.last.weight;
          reps = latest.setDetails.last.reps;
        }
      }
      workout.setDetails.add(SetEntry(weight, reps));
      notifyListeners();
      _saveData();
    }
  }

  void deleteSet(DateTime day, int workoutIndex, int setIndex) {
    final key = DateTime(day.year, day.month, day.day);
    final workout = _workoutData[key]?[workoutIndex];
    if (workout != null && setIndex < workout.setDetails.length) {
      workout.setDetails.removeAt(setIndex);
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

  void updateIntensity(
      DateTime day, int workoutIndex, IntensityLevel intensity) {
    final key = DateTime(day.year, day.month, day.day);
    final workout = _workoutData[key]?[workoutIndex];
    if (workout != null) {
      workout.intensity = intensity;
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
