import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 운동 기록 페이지를 드래그로 펼칠 수 있는 시트 위젯 파일
import '../providers/workout_data.dart';
import '../pages/add_workout_page.dart';
import '../pages/workout_log_page.dart';
// 홈 화면에서 사용되는 드래그 가능한 운동 기록 시트 위젯
class WorkoutLogSheet extends StatefulWidget {
  final DateTime? selectedDay;
  final DraggableScrollableController controller;

  const WorkoutLogSheet({
    super.key,
    required this.selectedDay,
    required this.controller,
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
    return DraggableScrollableSheet(
      controller: widget.controller,
      minChildSize: 0.1,
      initialChildSize: 0.15,
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
              GestureDetector(
                onTap: () => widget.controller.animateTo(
                  1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: WorkoutLogBody(
                  selectedDay: widget.selectedDay,
                  onAddWorkout: _openAddWorkoutPage,
                  onDeleteWorkout: _deleteWorkout,
                  controller: scrollController,
                  showOnlyHeader: !_expanded,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
