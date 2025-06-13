import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/workout_data.dart';

class WorkoutLogSection extends StatelessWidget {
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
                selectedDay != null
                    ? '${selectedDay!.month}월 ${selectedDay!.day}일 운동 기록'
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
    final workouts = provider.workoutsForDay(selectedDay ?? DateTime.now());

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
                onPressed: onAddWorkout,
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
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getIntensityColor(workout.intensity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '강도 ${workout.intensity}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () => onDeleteWorkout(index),
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
}
