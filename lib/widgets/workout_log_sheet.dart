import 'package:flutter/material.dart';
// 운동 기록 페이지를 드래그로 펼칠 수 있는 시트 위젯 파일
import '../pages/workout_log_page.dart';
// 공통 동작을 위한 유틸 함수
import '../utils/workout_log_utils.dart';

/// Bottom sheet variant of [WorkoutLogPage]. It embeds [WorkoutLogBody]
/// inside a [DraggableScrollableSheet] so the user can drag it up from the
/// calendar view.
// 홈 화면에서 사용되는 드래그 가능한 운동 기록 시트 위젯
class WorkoutLogSheet extends StatefulWidget {
  final DateTime? selectedDay;
  final DraggableScrollableController controller;
  final void Function(double)? onScroll;

  const WorkoutLogSheet({
    super.key,
    required this.selectedDay,
    required this.controller,
    this.onScroll,
  });

  @override
  State<WorkoutLogSheet> createState() => _WorkoutLogSheetState();
}

// 시트의 실제 동작을 담당하는 상태 클래스
class _WorkoutLogSheetState extends State<WorkoutLogSheet> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleDrag);
  }

  /// When the sheet is dragged past a certain threshold it automatically
  /// expands to full height. Dragging it back down collapses it again.
  void _handleDrag() {
    if (!_expanded && widget.controller.size > 0.3) {
      _expanded = true;
      widget.controller.animateTo(
        1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else if (_expanded && widget.controller.size <= 0.15) {
      _expanded = false;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleDrag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: widget.controller,
      minChildSize: 0.0,
      initialChildSize: 0.1,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          child: Column(
            children: [
              // Reuse the same body widget as the full page.
              Expanded(
                child: WorkoutLogBody(
                  selectedDay: widget.selectedDay,
                  onAddWorkout: () =>
                      openAddWorkoutPage(context, widget.selectedDay!),
                  onDeleteWorkout: (i) =>
                      deleteWorkout(context, widget.selectedDay!, i),
                  controller: scrollController,
                  showOnlyHeader: !_expanded,
                  sheetController: widget.controller,
                  onScroll: widget.onScroll,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
