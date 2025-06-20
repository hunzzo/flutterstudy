import 'package:flutter/material.dart';
// 운동 기록 페이지를 드래그로 펼칠 수 있는 시트 위젯 파일
import '../pages/workout_log_page.dart';
// 공통 동작을 위한 유틸 함수
import '../utils/workout_log_utils.dart';

/// [WorkoutLogPage]를 시트 형태로 보여 주어 달력 화면에서 위로 끌어올릴 수 있다.
// 홈 화면에서 사용되는 드래그 가능한 운동 기록 시트 위젯
class WorkoutLogSheet extends StatefulWidget {
  final DateTime? selectedDay;
  final DraggableScrollableController controller;
  final void Function(double)? onScroll;
  final Key? containerKey;

  const WorkoutLogSheet({
    super.key,
    required this.selectedDay,
    required this.controller,
    this.onScroll,
    this.containerKey,
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

  /// 시트를 일정 크기 이상 끌어올리면 자동으로 전체 높이로 확장되고
  /// 다시 아래로 내리면 접힌다.
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
      minChildSize: 0.1,
      initialChildSize: 0.1,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          key: widget.containerKey,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          child: Column(
            children: [
              // 전체 화면에서 사용하는 본문 위젯을 그대로 재사용한다.
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
