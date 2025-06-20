import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';

// 운동 데이터 제공자
import '../providers/workout_data.dart';
import '../models/workout.dart';
//import '../widgets/editable_number.dart';
// 공통 동작을 모아둔 유틸 함수
import '../utils/workout_log_utils.dart';

/// This file defines both the full screen workout log page and the reusable
/// [WorkoutLogBody] widget that is also embedded in [WorkoutLogSheet]. The
/// sheet simply wraps this body in a [DraggableScrollableSheet].

// 전체 화면이나 시트에서 재사용할 운동 기록 목록 본문 위젯
class WorkoutLogBody extends StatefulWidget {
  final DateTime? selectedDay;
  final ScrollController? controller;
  final VoidCallback onAddWorkout;
  final void Function(int) onDeleteWorkout;
  final bool showOnlyHeader;
  final DraggableScrollableController? sheetController;
  final void Function(double)? onScroll;

  const WorkoutLogBody({
    super.key,
    required this.selectedDay,
    this.controller,
    required this.onAddWorkout,
    required this.onDeleteWorkout,
    this.showOnlyHeader = false,
    this.sheetController,
    this.onScroll,
  });

  @override
  State<WorkoutLogBody> createState() => _WorkoutLogBodyState();
}

// WorkoutLogBody의 상태 클래스
class _WorkoutLogBodyState extends State<WorkoutLogBody> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.onScroll != null && widget.controller != null) {
      widget.onScroll!(widget.controller!.offset);
    }
  }

  @override
  void didUpdateWidget(covariant WorkoutLogBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onScroll);
      widget.controller?.addListener(_onScroll);
    }
    if (!isSameDay(oldWidget.selectedDay, widget.selectedDay)) {
      final controller = widget.controller;
      if (controller != null && controller.hasClients) {
        controller.jumpTo(controller.position.minScrollExtent);
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showOnlyHeader) {
      return ListView(
        controller: widget.controller,
        children: [
          WorkoutLogSection(
            selectedDay: widget.selectedDay,
            onAddWorkout: widget.onAddWorkout,
            onDeleteWorkout: widget.onDeleteWorkout,
            showOnlyHeader: true,
            sheetController: widget.sheetController,
          ),
        ],
      );
    }

    return ListView(
      controller: widget.controller,
      children: [
        WorkoutLogSection(
          selectedDay: widget.selectedDay,
          onAddWorkout: widget.onAddWorkout,
          onDeleteWorkout: widget.onDeleteWorkout,
          showOnlyHeader: false,
          sheetController: widget.sheetController,
        ),
        const SizedBox(height: 80),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Reusable body shared with [WorkoutLogSheet]. Includes sliver app bar.
      body: WorkoutLogBody(
        selectedDay: widget.selectedDay,
        onAddWorkout: () => openAddWorkoutPage(context, widget.selectedDay!),
        onDeleteWorkout: (i) => deleteWorkout(context, widget.selectedDay!, i),
        sheetController: null,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAddWorkoutPage(context, widget.selectedDay!),
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
  void didUpdateWidget(covariant WorkoutLogSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(oldWidget.selectedDay, widget.selectedDay)) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? Colors.grey[900] : Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.selectedDay != null
                          ? '${widget.selectedDay!.month}월 ${widget.selectedDay!.day}일 운동 기록'
                          : '오늘의 운동 기록',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: widget.onAddWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: Text(
                        '운동 기록 추가',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          _buildWorkoutList(context),
        ],
      ),
    );
  }

  Widget _buildWorkoutList(BuildContext context) {
    final provider = Provider.of<WorkoutData>(context);
    final workouts = provider.workoutsForDay(
      widget.selectedDay ?? DateTime.now(),
    );

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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: widget.onAddWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text(
                  '운동 기록 추가',
                  style: TextStyle(color: Colors.white),
                ),
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
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(51),
                    child: Icon(
                      Icons.fitness_center,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    workout.exercise,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(workout.maxVolumeSummary),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _editIntensity(context, index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getIntensityColor(workout.intensity),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            workout.intensity.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Provider.of<WorkoutData>(
                            context,
                            listen: false,
                          ).addSet(widget.selectedDay ?? DateTime.now(), index);
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
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) {
                            Provider.of<WorkoutData>(
                              context,
                              listen: false,
                            ).deleteSet(
                              widget.selectedDay ?? DateTime.now(),
                              index,
                              i,
                            );
                          },
                          child: _SetRow(
                            day: widget.selectedDay ?? DateTime.now(),
                            workoutIndex: index,
                            setIndex: i,
                            onToggle: () => _startRestTimer(context),
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

  Color _getIntensityColor(IntensityLevel level) {
    switch (level) {
      case IntensityLevel.warmup:
        return Colors.green;
      case IntensityLevel.low:
        return Colors.lightGreen;
      case IntensityLevel.medium:
        return Colors.orange;
      case IntensityLevel.high:
        return Colors.red;
    }
  }

  void _editIntensity(BuildContext context, int workoutIndex) {
    final provider = Provider.of<WorkoutData>(context, listen: false);
    final workouts = provider.workoutsForDay(
      widget.selectedDay ?? DateTime.now(),
    );
    final current = workouts[workoutIndex].intensity;
    int selectedIndex = IntensityLevel.values.indexOf(current);
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  itemExtent: 32,
                  onSelectedItemChanged: (i) => selectedIndex = i,
                  children: IntensityLevel.values
                      .map((e) => Center(child: Text(e.label)))
                      .toList(),
                ),
              ),
              TextButton(
                onPressed: () {
                  provider.updateIntensity(
                    widget.selectedDay ?? DateTime.now(),
                    workoutIndex,
                    IntensityLevel.values[selectedIndex],
                  );
                  Navigator.pop(context);
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      },
    );
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
    if (widget.sheetController != null && widget.sheetController!.size < 0.25) {
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

  const RestTimerBar({
    super.key,
    required this.duration,
    required this.onFinished,
  });

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
    final progress = 1 - _secondsLeft / widget.duration.inSeconds.toDouble();
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
            Text('$_secondsLeft초', style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  final DateTime day;
  final int workoutIndex;
  final int setIndex;
  final VoidCallback onToggle;

  const _SetRow({
    required this.day,
    required this.workoutIndex,
    required this.setIndex,
    required this.onToggle,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutData>(context);
    final workout = provider.workoutsForDay(widget.day)[widget.workoutIndex];
    final set = workout.setDetails[widget.setIndex];

    return Column(
      children: [
        Material(
          color: set.done
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: InkWell(
            onTap: () {
              provider.toggleSetDone(
                widget.day,
                widget.workoutIndex,
                widget.setIndex,
              );
              widget.onToggle();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${set.weight.toStringAsFixed(1)}kg x ${set.reps}'),
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => provider.updateSet(
                        widget.day,
                        widget.workoutIndex,
                        widget.setIndex,
                        weight: set.weight - 2.5,
                      ),
                    ),
                    Text('${set.weight.toStringAsFixed(1)}kg'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => provider.updateSet(
                        widget.day,
                        widget.workoutIndex,
                        widget.setIndex,
                        weight: set.weight + 2.5,
                      ),
                    ),
                  ],
                ),
                Row(
                  //mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => provider.updateSet(
                        widget.day,
                        widget.workoutIndex,
                        widget.setIndex,
                        reps: set.reps - 1,
                      ),
                    ),
                    Text('${set.reps}회'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => provider.updateSet(
                        widget.day,
                        widget.workoutIndex,
                        widget.setIndex,
                        reps: set.reps + 1,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
