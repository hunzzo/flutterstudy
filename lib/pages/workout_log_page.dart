import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/home_sections/workout_log_section.dart';
import '../providers/workout_data.dart';
import 'add_workout_page.dart';

class WorkoutLogPage extends StatefulWidget {
  final DateTime? selectedDay;
  const WorkoutLogPage({super.key, required this.selectedDay});

  @override
  State<WorkoutLogPage> createState() => _WorkoutLogPageState();
}

class _WorkoutLogPageState extends State<WorkoutLogPage> {
  void _openAddWorkoutPage() {
    final selectedDate = DateTime(
      widget.selectedDay!.year,
      widget.selectedDay!.month,
      widget.selectedDay!.day,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddWorkoutPage(selectedDate: selectedDate),
      ),
    );
  }

  void _deleteWorkout(int index) {
    final selectedDate = DateTime(
      widget.selectedDay!.year,
      widget.selectedDay!.month,
      widget.selectedDay!.day,
    );

    final provider = Provider.of<WorkoutData>(context, listen: false);
    provider.deleteWorkout(selectedDate, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 운동')),
      body: WorkoutLogSection(
        selectedDay: widget.selectedDay,
        onAddWorkout: _openAddWorkoutPage,
        onDeleteWorkout: _deleteWorkout,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddWorkoutPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
