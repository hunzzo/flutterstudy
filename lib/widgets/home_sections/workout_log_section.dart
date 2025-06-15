import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../providers/workout_data.dart';
import '../../models/workout.dart';
import '../editable_number.dart';

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
                        onPressed: () {
                          Provider.of<WorkoutData>(context, listen: false).addSet(
                              widget.selectedDay ?? DateTime.now(),
                              index,
                              SetEntry(0, 0));
                        },
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
                        child: Dismissible(
                          key: ValueKey('set_${index}_$i'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            color: Colors.red,
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            Provider.of<WorkoutData>(context, listen: false)
                                .deleteSet(widget.selectedDay ?? DateTime.now(),
                                    index, i);
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: workout.setDetails[i].done
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                foregroundColor: workout.setDetails[i].done
                                    ? Colors.white
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                              ),
                              onPressed: () {
                                Provider.of<WorkoutData>(context, listen: false)
                                    .toggleSetDone(
                                        widget.selectedDay ?? DateTime.now(),
                                        index,
                                        i);
                                _startRestTimer(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  EditableNumber(
                                    value: workout.setDetails[i].weight,
                                    onChanged: (v) {
                                      Provider.of<WorkoutData>(context,
                                              listen: false)
                                          .updateSet(
                                              widget.selectedDay ??
                                                  DateTime.now(),
                                              index,
                                              i,
                                              weight: v.toDouble());
                                    },
                                  ),
                                  const Text('kg x '),
                                  EditableNumber(
                                    value: workout.setDetails[i].reps,
                                    integer: true,
                                    onChanged: (v) {
                                      Provider.of<WorkoutData>(context,
                                              listen: false)
                                          .updateSet(widget.selectedDay ??
                                              DateTime.now(), index, i,
                                              reps: v.toInt());
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
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


  void _startRestTimer(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const RestTimerDialog(duration: Duration(seconds: 60)),
    );
  }
}

class RestTimerDialog extends StatefulWidget {
  final Duration duration;
  const RestTimerDialog({super.key, required this.duration});

  @override
  State<RestTimerDialog> createState() => _RestTimerDialogState();
}

class _RestTimerDialogState extends State<RestTimerDialog> {
  late int _secondsLeft;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.duration.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        if (mounted) Navigator.of(context).pop();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        1 - _secondsLeft / widget.duration.inSeconds.toDouble();
    return AlertDialog(
      title: const Text('휴식 중'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$_secondsLeft초 남음'),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: progress),
        ],
      ),
    );
  }
}
