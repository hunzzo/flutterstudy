import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

//import '../models/workout.dart';
import '../widgets/home_sections/calendar_section.dart';
import '../widgets/home_sections/favorite_progress_section.dart';
//import '../widgets/home_sections/muscle_recovery_section.dart';
import '../widgets/home_sections/muscle_volume_section.dart';
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
  // 슬리버 앱바 제어용 스크롤 컨트롤러
  late ScrollController _scrollController;
  double _logScrollOffset = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _pageController = PageController(initialPage: _currentPage);
    _sheetController = DraggableScrollableController();
    _scrollController = ScrollController();
    _sheetController.addListener(_handleSheetDrag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        minimum: const EdgeInsets.only(top: 48),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: false,
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
                    PopupMenuItem(value: 'settings', child: Text('설정')),
                  ],
                ),
              ],
            ),
            SliverFillRemaining(
              child: PageView(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor:
                              Theme.of(context).colorScheme.primary,
                          tabs: const [
                            Tab(text: '근육별 최근 기록'),
                            Tab(text: '즐겨찾기 무게 추세'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              MuscleVolumeSection(),
                              FavoriteProgressSection(),
                            ],
                          ),
                        ),
                      ],
                    ),
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
    _updateAppBarOffset();
  }

  void _handleLogScroll(double offset) {
    _logScrollOffset = offset.clamp(0.0, kToolbarHeight);
    _updateAppBarOffset();
  }

  void _updateAppBarOffset() {
    if (!_scrollController.hasClients) return;
    final baseOffset = (_sheetController.size.clamp(0.0, 1.0)) * kToolbarHeight;
    final combined = (baseOffset + _logScrollOffset).clamp(0.0, kToolbarHeight);
    _scrollController.jumpTo(combined);
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
    _scrollController.dispose();
    super.dispose();
  }
}
