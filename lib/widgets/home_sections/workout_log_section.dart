import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/workout_data.dart';
import '../../models/workout.dart';

class WorkoutLogSection extends StatefulWidget {
  final DateTime? selectedDay;
  final VoidCallback onAddWorkout;
  final void Function(int) onDeleteWorkout;

  const WorkoutLogSection({
    super.key,
    required this.selectedDay,
    required this.onAddWorkout,
    required this.onDeleteWorkout,
  });

  @override
  State<WorkoutLogSection> createState() => _WorkoutLogSectionState();
}

class _WorkoutLogSectionState extends State<WorkoutLogSection> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? Colors.grey[900] : Colors.grey[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                widget.selectedDay != null
                    ? '${widget.selectedDay!.month}월 ${widget.selectedDay!.day}일 운동 기록'
                    : '오늘의 운동 기록',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWorkoutList(context),
        ],
      ),
    );
  }

  Widget _buildWorkoutList(BuildContext context) {
    final provider = Provider.of<WorkoutData>(context);
    final workouts = provider.workoutsForDay(widget.selectedDay ?? DateTime.now());

    if (workouts.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_gymnastics, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                '이 날의 운동 기록이 없습니다',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: widget.onAddWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary,
                ),
                child: const Text('운동 기록 추가'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withAlpha(51),
                    child: Icon(Icons.fitness_center,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(
                    workout.exercise,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${workout.sets} | ${workout.details}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getIntensityColor(workout.intensity),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '강도 ${workout.intensity}',
                          style:
                              const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _showAddSetDialog(context, index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[400]),
                        onPressed: () => widget.onDeleteWorkout(index),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < workout.setDetails.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: ChoiceChip(
                          label: Text(
                              '${workout.setDetails[i].weight}kg x ${workout.setDetails[i].reps}'),
                          selected: workout.setDetails[i].done,
                          onSelected: (_) {
                            Provider.of<WorkoutData>(context, listen: false)
                                .toggleSetDone(
                                    widget.selectedDay ?? DateTime.now(),
                                    index,
                                    i);
                            _startRestTimer(context);
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getIntensityColor(int intensity) {
    if (intensity <= 3) return Colors.green;
    if (intensity <= 6) return Colors.orange;
    return Colors.red;
  }

  void _showAddSetDialog(BuildContext context, int workoutIndex) async {
    final weightController = TextEditingController();
    final repsController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('세트 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '무게(kg)'),
            ),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '횟수'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('추가'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;

    if (result == true) {
      final weight = double.tryParse(weightController.text) ?? 0;
      final reps = int.tryParse(repsController.text) ?? 0;
      Provider.of<WorkoutData>(context, listen: false).addSet(
          widget.selectedDay ?? DateTime.now(),
          workoutIndex,
          SetEntry(weight, reps));
    }
  }

  void _startRestTimer(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('휴식 시작!'), duration: Duration(seconds: 1)),
    );
    Future.delayed(const Duration(seconds: 60), () {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('휴식 종료'), duration: Duration(seconds: 1)),
      );
    });
  }
}
