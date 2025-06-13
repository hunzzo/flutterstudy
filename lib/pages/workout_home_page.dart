import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/workout.dart';
import '../widgets/home_sections/muscle_recovery_section.dart';
import '../widgets/home_sections/calendar_section.dart';
import '../widgets/home_sections/scroll_hint_section.dart';
import '../widgets/home_sections/workout_log_section.dart';
import 'settings_page.dart';
import '../providers/workout_data.dart';

import 'package:provider/provider.dart';

class WorkoutHomePage extends StatefulWidget {
  @override
  _WorkoutHomePageState createState() => _WorkoutHomePageState();
}

class _WorkoutHomePageState extends State<WorkoutHomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 기록'),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),

            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: MuscleRecoverySection()),
          SliverToBoxAdapter(
            child: CalendarSection(
              calendarFormat: _calendarFormat,
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          const SliverToBoxAdapter(child: ScrollHintSection()),
          SliverToBoxAdapter(
            child: WorkoutLogSection(
              selectedDay: _selectedDay,
              onAddWorkout: _showAddWorkoutDialog,
              onDeleteWorkout: _deleteWorkout,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWorkoutDialog,
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddWorkoutDialog() {
    final exerciseController = TextEditingController();
    final setsController = TextEditingController();
    final detailsController = TextEditingController();
    MuscleGroup selectedMuscle = MuscleGroup.chest;
    int selectedIntensity = 5;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('운동 기록 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: exerciseController,
                      decoration: const InputDecoration(
                        labelText: '운동명',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: setsController,
                      decoration: const InputDecoration(
                        labelText: '세트 수',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: detailsController,
                      decoration: const InputDecoration(
                        labelText: '상세 정보 (무게, 횟수 등)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<MuscleGroup>(
                      value: selectedMuscle,
                      isExpanded: true,
                      items: MuscleGroup.values.map((muscle) {
                        return DropdownMenuItem(
                          value: muscle,
                          child: Text(muscle.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedMuscle = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('운동 강도: $selectedIntensity'),
                    Slider(
                      value: selectedIntensity.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedIntensity = value.round();
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (exerciseController.text.isNotEmpty) {
                      _addWorkout(
                        exerciseController.text,
                        setsController.text,
                        detailsController.text,
                        selectedMuscle,
                        selectedIntensity,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                  ),
                  child: const Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addWorkout(
    String exercise,
    String sets,
    String details,
    MuscleGroup muscle,
    int intensity,
  ) {
    final selectedDate = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    final provider = Provider.of<WorkoutData>(context, listen: false);
    provider.addWorkout(
      selectedDate,
      WorkoutRecord(exercise, sets, details, muscle, intensity),
    );
  }

  void _deleteWorkout(int index) {
    final selectedDate = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    final provider = Provider.of<WorkoutData>(context, listen: false);
    provider.deleteWorkout(selectedDate, index);
  }
}
