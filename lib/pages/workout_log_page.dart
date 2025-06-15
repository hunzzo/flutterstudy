import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 운동 기록 목록을 보여주는 섹션 위젯
import '../widgets/home_sections/workout_log_section.dart';
// 운동 데이터 제공자
import '../providers/workout_data.dart';
// 운동 추가 페이지
import 'add_workout_page.dart';

// 전체 화면이나 시트에서 재사용할 운동 기록 목록 본문 위젯
class WorkoutLogBody extends StatefulWidget {
  final DateTime? selectedDay;
  final ScrollController? controller;
  final VoidCallback onAddWorkout;
  final void Function(int) onDeleteWorkout;
  final bool showOnlyHeader;

  const WorkoutLogBody({
    super.key,
    required this.selectedDay,
    this.controller,
    required this.onAddWorkout,
    required this.onDeleteWorkout,
    this.showOnlyHeader = false,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddWorkoutPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
