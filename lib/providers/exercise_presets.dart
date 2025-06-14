import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout.dart';

class ExercisePresets extends ChangeNotifier {
  static const String _storageKey = 'exercisePresets';
  static const String _favoritesKey = 'exerciseFavorites';

  List<String> _presets = [
    'Bench Press',
    'Squat',
    'Deadlift',
    'Overhead Press',
    'Bent Over Row',
    'Pull Up',
    'Chin Up',
    'Dip',
    'Push Up',
    'Lunge',
    'Leg Press',
    'Leg Curl',
    'Leg Extension',
    'Calf Raise',
    'Bicep Curl',
    'Tricep Pushdown',
    'Tricep Extension',
    'Hammer Curl',
    'Cable Row',
    'Lat Pulldown',
    'Chest Fly',
    'Incline Bench Press',
    'Decline Bench Press',
    'Dumbbell Press',
    'Dumbbell Row',
    'Dumbbell Fly',
    'Shoulder Press',
    'Lateral Raise',
    'Front Raise',
    'Rear Delt Fly',
    'Shrug',
    'Upright Row',
    'Ab Crunch',
    'Plank',
    'Russian Twist',
    'Leg Raise',
    'Hanging Leg Raise',
    'Hip Thrust',
    'Glute Bridge',
    'Step Up',
    'Bulgarian Split Squat',
    'Sumo Deadlift',
    'Romanian Deadlift',
    'Good Morning',
    'Back Extension',
    'Cable Crossover',
    'Pec Deck',
    'Chest Dip',
    'Push Press',
    'Clean and Jerk',
    'Snatch',
    'Power Clean',
    'Kettlebell Swing',
    'Farmers Walk',
    'Battle Ropes',
    'Medicine Ball Slam',
    'Box Jump',
    'Jump Squat',
    'Burpee',
    'Mountain Climber',
    'Jump Rope',
    'Rowing Machine',
    'Cycling',
    'Running',
    'Stair Climber',
    'Elliptical',
    'Swimming',
    'Pilates',
    'Yoga',
    'Stretching',
    'Foam Rolling',
    'Arm Circle',
    'Wall Sit',
    'Plank Row',
    'Cable Kickback',
    'Cable Lateral Raise',
    'Leg Adduction',
    'Leg Abduction',
    'Cable Woodchop',
    'Face Pull',
    'Skull Crusher',
    'Close Grip Bench Press',
    'Cable Curl',
    'Concentration Curl',
    'Preacher Curl',
    'Incline Curl',
    'Wrist Curl',
    'Reverse Wrist Curl',
    'Neck Curl',
    'Neck Extension',
    'Reverse Fly',
    'Seated Row',
    'Glute Ham Raise',
    'Sled Push',
    'Sled Pull',
    'Pistol Squat',
    'One Arm Row',
    'Cable Row Seated',
    'Cable Pullover',
    'T-Bar Row',
  ];

  Set<String> _favorites = {};

  ExercisePresets() {
    _loadPresets();
    _loadFavorites();
  }

  List<String> get presets => List.unmodifiable(_presets);

  void addPreset(String preset) {
    if (preset.isEmpty) return;
    if (!_presets.contains(preset)) {
      _presets.add(preset);
      _savePresets();
      notifyListeners();
    }
  }

  Future<void> _loadPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> list = jsonDecode(jsonString);
      _presets = list.cast<String>();
    }
  }

  Future<void> _savePresets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_presets));
  }

  // --- Favorites management ---
  bool isFavorite(String exercise) => _favorites.contains(exercise);

  void toggleFavorite(String exercise) {
    if (_favorites.contains(exercise)) {
      _favorites.remove(exercise);
    } else {
      _favorites.add(exercise);
    }
    _saveFavorites();
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);
    if (jsonString != null) {
      final List<dynamic> list = jsonDecode(jsonString);
      _favorites = list.cast<String>().toSet();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoritesKey, jsonEncode(_favorites.toList()));
  }

  /// Utility to guess muscle group based on exercise name
  MuscleGroup muscleGroupFor(String exercise) {
    final name = exercise.toLowerCase();
    if (name.contains('bench') || name.contains('chest') || name.contains('fly')) {
      return MuscleGroup.chest;
    }
    if (name.contains('squat') || name.contains('lunge') || name.contains('leg') || name.contains('calf')) {
      return MuscleGroup.legs;
    }
    if (name.contains('shoulder') || name.contains('press') && name.contains('overhead') || name.contains('delt')) {
      return MuscleGroup.shoulders;
    }
    if (name.contains('row') || name.contains('pull') || name.contains('deadlift') || name.contains('back')) {
      return MuscleGroup.back;
    }
    if (name.contains('bicep') || name.contains('tricep') || name.contains('curl')) {
      return MuscleGroup.arms;
    }
    if (name.contains('ab') || name.contains('plank') || name.contains('core')) {
      return MuscleGroup.core;
    }
    return MuscleGroup.chest;
  }
}
