import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

//import '../models/workout.dart';
import '../widgets/home_sections/calendar_section.dart';
import '../widgets/home_sections/workout_log_section.dart';
import '../widgets/home_sections/muscle_recovery_section.dart';
import 'settings_page.dart';
import '../providers/workout_data.dart';
import 'add_workout_page.dart';
import 'package:provider/provider.dart';

class WorkoutHomePage extends StatefulWidget {
  const WorkoutHomePage({super.key});

  @override
  WorkoutHomePageState createState() => WorkoutHomePageState();
}

class WorkoutHomePageState extends State<WorkoutHomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final PageController _pageController =
      PageController(initialPage: 1, viewportFraction: .9);
  int _currentPage = 1;

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

        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'settings',
                child: Text('설정'),
              ),
            ],

          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          const MuscleRecoverySection(),
          CalendarSection(
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
              _showWorkoutPreview(selectedDay);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          WorkoutLogSection(
            selectedDay: _selectedDay,
            onAddWorkout: _openAddWorkoutPage,
            onDeleteWorkout: _deleteWorkout,
          ),
        ],
      ),
      floatingActionButton: _currentPage == 2
          ? FloatingActionButton(
              onPressed: _openAddWorkoutPage,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _openAddWorkoutPage() {
    final selectedDate = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddWorkoutPage(selectedDate: selectedDate),
      ),
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

  void _showWorkoutPreview(DateTime day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          maxChildSize: 1,
          builder: (context, controller) {
            return Material(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SingleChildScrollView(
                controller: controller,
                child: WorkoutLogSection(
                  selectedDay: day,
                  onAddWorkout: _openAddWorkoutPage,
                  onDeleteWorkout: _deleteWorkout,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
