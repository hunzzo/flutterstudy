import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// 운동 데이터 제공자
import '../providers/workout_data.dart';
import '../models/workout.dart';
import '../widgets/editable_number.dart';
// 운동 추가 페이지
import 'add_workout_page.dart';

// 전체 화면이나 시트에서 재사용할 운동 기록 목록 본문 위젯
class WorkoutLogBody extends StatefulWidget {
  final DateTime? selectedDay;
  final ScrollController? controller;
  final VoidCallback onAddWorkout;
  final void Function(int) onDeleteWorkout;
  final bool showOnlyHeader;
  final DraggableScrollableController? sheetController;

  const WorkoutLogBody({
    super.key,
    required this.selectedDay,
    this.controller,
    required this.onAddWorkout,
    required this.onDeleteWorkout,
    this.showOnlyHeader = false,
    this.sheetController,
  });

  @override
  State<WorkoutLogBody> createState() => _WorkoutLogBodyState();
}

// WorkoutLogBody의 상태 클래스
class _WorkoutLogBodyState extends State<WorkoutLogBody> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.controller,
      children: [
        WorkoutLogSection(
          selectedDay: widget.selectedDay,
          onAddWorkout: widget.onAddWorkout,
          onDeleteWorkout: widget.onDeleteWorkout,
          showOnlyHeader: widget.showOnlyHeader,
          sheetController: widget.sheetController,
        ),
        if (!widget.showOnlyHeader) const SizedBox(height: 80),
      ],
    );
  }
}

// 전체 화면에서 사용하는 운동 기록 페이지
class WorkoutLogPage extends StatefulWidget {
  final DateTime? selectedDay;
  const WorkoutLogPage({super.key, required this.selectedDay});

  @override
  State<WorkoutLogPage> createState() => _WorkoutLogPageState();
}

// WorkoutLogPage의 상태 클래스
class _WorkoutLogPageState extends State<WorkoutLogPage> {
  // 운동 추가 페이지로 이동
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

  // 운동 기록 삭제 처리
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
      body: WorkoutLogBody(
        selectedDay: widget.selectedDay,
        onAddWorkout: _openAddWorkoutPage,
        onDeleteWorkout: _deleteWorkout,
        sheetController: null,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddWorkoutPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --------- WorkoutLogSection and related widgets ---------

class WorkoutLogSection extends StatefulWidget {
  final DateTime? selectedDay;
  final VoidCallback onAddWorkout;
  final void Function(int) onDeleteWorkout;
  final bool showOnlyHeader;
  final DraggableScrollableController? sheetController;

  const WorkoutLogSection({
    super.key,
    required this.selectedDay,
    required this.onAddWorkout,
    required this.onDeleteWorkout,
    this.showOnlyHeader = false,
    this.sheetController,
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
          if (!widget.showOnlyHeader) ...[
            const SizedBox(height: 16),
            _buildWorkoutList(context),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkoutList(BuildContext context) {
    final provider = Provider.of<WorkoutData>(context);
    final workouts =
        provider.workoutsForDay(widget.selectedDay ?? DateTime.now());

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
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
      itemCount: workouts.length + 1,
      itemBuilder: (context, index) {
        if (index == workouts.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton(
              onPressed: widget.onAddWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('운동 추가'),
            ),
          );
        }
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
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            Provider.of<WorkoutData>(context, listen: false)
                                .deleteSet(widget.selectedDay ?? DateTime.now(),
                                    index, i);
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Material(
                              color: workout.setDetails[i].done
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surfaceVariant,
                              child: InkWell(
                                onTap: () {
                                  Provider.of<WorkoutData>(context, listen: false)
                                      .toggleSetDone(
                                          widget.selectedDay ?? DateTime.now(),
                                          index,
                                          i);
                                  _startRestTimer(context);
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
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
                                              .updateSet(
                                                  widget.selectedDay ??
                                                      DateTime.now(),
                                                  index,
                                                  i,
                                                  reps: v.toInt());
                                        },
                                      ),
                                    ],
                                  ),
                                ),
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

  OverlayEntry? _restEntry;

  void _startRestTimer(BuildContext context) {
    _restEntry?.remove();
    _restEntry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: RestTimerBar(
          duration: const Duration(seconds: 60),
          onFinished: () {
            _restEntry?.remove();
            _restEntry = null;
          },
        ),
      ),
    );
    Overlay.of(context).insert(_restEntry!);
    if (widget.sheetController != null &&
        widget.sheetController!.size < 0.25) {
      widget.sheetController!.animateTo(
        0.25,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

class RestTimerBar extends StatefulWidget {
  final Duration duration;
  final VoidCallback onFinished;

  const RestTimerBar({super.key, required this.duration, required this.onFinished});

  @override
  State<RestTimerBar> createState() => _RestTimerBarState();
}

class _RestTimerBarState extends State<RestTimerBar> {
  late int _secondsLeft;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.duration.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        widget.onFinished();
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
    return Material(
      elevation: 4,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$_secondsLeft초',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
