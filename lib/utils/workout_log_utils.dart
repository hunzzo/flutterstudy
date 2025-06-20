import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/add_workout_page.dart';
import '../providers/workout_data.dart';

/// 주어진 [selectedDay]에 대한 [AddWorkoutPage]를 연다.
void openAddWorkoutPage(BuildContext context, DateTime selectedDay) {
  final date = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AddWorkoutPage(selectedDate: date),
    ),
  );
}

/// [selectedDay]의 운동 기록 중 [index]에 해당하는 항목을 삭제한다.
void deleteWorkout(BuildContext context, DateTime selectedDay, int index) {
  final date = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
  final provider = Provider.of<WorkoutData>(context, listen: false);
  provider.deleteWorkout(date, index);
}
