import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

//import '../models/workout.dart';
import '../widgets/home_sections/calendar_section.dart';
import '../widgets/home_sections/muscle_recovery_section.dart';
import 'settings_page.dart';

import '../widgets/workout_log_sheet.dart';

// 홈 화면 페이지로 달력과 운동 기록 시트를 포함한다
class WorkoutHomePage extends StatefulWidget {
  const WorkoutHomePage({super.key});

  @override
  WorkoutHomePageState createState() => WorkoutHomePageState();
}

// 홈 페이지의 상태 관리 클래스
class WorkoutHomePageState extends State<WorkoutHomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late PageController _pageController;
  // 운동 기록 시트 제어용 컨트롤러
  late DraggableScrollableController _sheetController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _pageController = PageController(
      initialPage: _currentPage,
    );
    _sheetController = DraggableScrollableController();
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
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          MuscleRecoverySection(
            onScrollDownFromFavorites: _goToCalendar,
          ),
          Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: _handleCalendarHorizontalDrag,
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
                    _sheetController.animateTo(
                      1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ),
              WorkoutLogSheet(
                selectedDay: _selectedDay,
                controller: _sheetController,
              ),
            ],
          ),
        ],
      ),
    );
  }
  // 달력을 좌우로 넘길 때 사용되는 드래그 핸들러
  void _handleCalendarHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == null) return;
    if (details.primaryVelocity! < 0) {
      setState(() {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
      });
    } else if (details.primaryVelocity! > 0) {
      setState(() {
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      });
    }
  }

  void _goToCalendar() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
