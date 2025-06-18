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
  // 운동 기록 스크롤 오프셋
  double _logScrollOffset = 0;
  int _currentPage = 1;

  double get _appBarProgress {
    const minSize = 0.1;
    final size = _sheetController.size.clamp(minSize, 1.0);
    final normalized = (size - minSize) / (1 - minSize);
    final sheetFactor = 1 - normalized;
    final scrollFactor = 1 - (_logScrollOffset / kToolbarHeight).clamp(0.0, 1.0);
    return (sheetFactor * scrollFactor).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _pageController = PageController(
      initialPage: _currentPage,
    );
    _sheetController = DraggableScrollableController();
    _sheetController.addListener(_handleSheetDrag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        minimum: const EdgeInsets.only(top: 48),
        child: Stack(
          children: [
            PageView(
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
                      onScroll: _handleLogScroll,
                    ),
                  ],
                ),
              ],
            ),
            _AnimatedHomeAppBar(
              progress: _appBarProgress,
              onMenuSelected: (value) {
                if (value == 'settings') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                }
              },
            ),
          ],
        ),
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

  // 드래그 시트 크기에 맞춰 앱바를 숨기기 위한 핸들러
  void _handleSheetDrag() {
    setState(() {});
  }

  void _handleLogScroll(double offset) {
    setState(() {
      _logScrollOffset = offset.clamp(0.0, kToolbarHeight);
    });
  }

  void _goToCalendar() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _sheetController.removeListener(_handleSheetDrag);
    _pageController.dispose();
    super.dispose();
  }
}

class _AnimatedHomeAppBar extends StatelessWidget {
  final double progress;
  final ValueChanged<String> onMenuSelected;

  const _AnimatedHomeAppBar({
    required this.progress,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final slide = -kToolbarHeight * (1 - progress);
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      top: slide,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: progress,
        child: AppBar(
          title: const Text('운동 기록'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              onSelected: onMenuSelected,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'settings',
                  child: Text('설정'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
