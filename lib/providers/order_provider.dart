import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout.dart';

class OrderProvider extends ChangeNotifier {
  static const String _favoriteKey = 'favoriteOrder';
  static const String _muscleKey = 'muscleOrder';

  List<String> _favoriteOrder = [];
  List<String> _muscleOrder = MuscleGroup.values.map((e) => e.name).toList();

  OrderProvider() {
    _load();
  }

  List<String> get favoriteOrder => List.unmodifiable(_favoriteOrder);
  List<String> get muscleOrder => List.unmodifiable(_muscleOrder);

  void reorderFavoriteList(List<String> current, int oldIndex, int newIndex) {
    if (_favoriteOrder.length != current.length) {
      _favoriteOrder = List.from(current);
    }
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _favoriteOrder.removeAt(oldIndex);
    _favoriteOrder.insert(newIndex, item);
    notifyListeners();
    _save();
  }

  void reorderMuscle(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _muscleOrder.removeAt(oldIndex);
    _muscleOrder.insert(newIndex, item);
    notifyListeners();
    _save();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteOrder = prefs.getStringList(_favoriteKey) ?? [];
    _muscleOrder =
        prefs.getStringList(_muscleKey) ?? MuscleGroup.values.map((e) => e.name).toList();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteKey, _favoriteOrder);
    await prefs.setStringList(_muscleKey, _muscleOrder);
  }
}
