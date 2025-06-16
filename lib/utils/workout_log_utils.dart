import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/add_workout_page.dart';
import '../providers/workout_data.dart';

/// Opens the [AddWorkoutPage] for the given [selectedDay].
void openAddWorkoutPage(BuildContext context, DateTime selectedDay) {
  final date = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AddWorkoutPage(selectedDate: date),
    ),
  );
}

/// Deletes a workout entry on [selectedDay] at the given [index].
void deleteWorkout(BuildContext context, DateTime selectedDay, int index) {
  final date = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
  final provider = Provider.of<WorkoutData>(context, listen: false);
  provider.deleteWorkout(date, index);
}
