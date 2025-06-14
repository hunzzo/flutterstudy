import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/exercise_presets.dart';
import '../providers/workout_data.dart';
import '../models/workout.dart';

class AddWorkoutPage extends StatefulWidget {
  final DateTime selectedDate;
  const AddWorkoutPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final List<String> _queue = [];

  @override
  Widget build(BuildContext context) {
    final presets = context.watch<ExercisePresets>().presets;
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 선택'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('추가', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 80,
            child: ReorderableListView(
              scrollDirection: Axis.horizontal,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _queue.removeAt(oldIndex);
                  _queue.insert(newIndex, item);
                });
              },
              children: [
                for (final ex in _queue)
                  Padding(
                    key: ValueKey(ex),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Chip(
                      label: Text(ex),
                      onDeleted: () {
                        setState(() {
                          _queue.remove(ex);
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.1,
              ),
              itemCount: presets.length,
              itemBuilder: (context, index) {
                final exercise = presets[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _queue.add(exercise);
                    });
                  },
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fitness_center, size: 32),
                        const SizedBox(height: 8),
                        Text(exercise, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final provider = context.read<WorkoutData>();
    for (final ex in _queue) {
      final last = provider.latestRecordForExercise(ex);
      if (last != null) {
        provider.addWorkout(
          widget.selectedDate,
          WorkoutRecord(ex, last.sets, last.details, last.muscleGroup, last.intensity),
        );
      } else {
        provider.addWorkout(
          widget.selectedDate,
          WorkoutRecord(ex, '', '', MuscleGroup.chest, 5),
        );
      }
    }
    Navigator.pop(context);
  }
}
