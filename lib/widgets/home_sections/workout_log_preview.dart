import 'package:flutter/material.dart';
import 'workout_log_section.dart';

class WorkoutLogPreview extends StatelessWidget {
  final DateTime? selectedDay;
  final VoidCallback onAddWorkout;
  final void Function(int) onDeleteWorkout;

  const WorkoutLogPreview({
    super.key,
    required this.selectedDay,
    required this.onAddWorkout,
    required this.onDeleteWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 0.2,
        child: WorkoutLogSection(
          selectedDay: selectedDay,
          onAddWorkout: onAddWorkout,
          onDeleteWorkout: onDeleteWorkout,
        ),
      ),
    );
  }
}
