import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(WorkoutApp());
}

class WorkoutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '운동 기록',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: WorkoutHomePage(),
    );
  }
}

class WorkoutHomePage extends StatefulWidget {
  @override
  _WorkoutHomePageState createState() => _WorkoutHomePageState();
}

class _WorkoutHomePageState extends State<WorkoutHomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 예시 운동 데이터
  Map<DateTime, List<WorkoutRecord>> _workoutData = {
    DateTime.now(): [
      WorkoutRecord('벤치프레스', '3세트', '80kg x 10회', MuscleGroup.chest, 8),
      WorkoutRecord('스쿼트', '4세트', '100kg x 8회', MuscleGroup.legs, 9),
      WorkoutRecord('데드리프트', '3세트', '120kg x 5회', MuscleGroup.back, 9),
    ],
    DateTime.now().subtract(Duration(days: 1)): [
      WorkoutRecord('풀업', '3세트', '체중 x 12회', MuscleGroup.back, 7),
      WorkoutRecord('딥스', '3세트', '체중 x 15회', MuscleGroup.chest, 6),
      WorkoutRecord('어깨 프레스', '4세트', '40kg x 12회', MuscleGroup.shoulders, 8),
    ],
    DateTime.now().subtract(Duration(days: 2)): [
      WorkoutRecord('바이셉 컬', '3세트', '15kg x 15회', MuscleGroup.arms, 6),
      WorkoutRecord('트라이셉 딥', '3세트', '체중 x 12회', MuscleGroup.arms, 7),
      WorkoutRecord('레그 프레스', '4세트', '150kg x 12회', MuscleGroup.legs, 8),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  List<WorkoutRecord> _getWorkoutsForDay(DateTime day) {
    return _workoutData[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Map<MuscleGroup, MuscleRecoveryInfo> _getMuscleRecoveryStatus() {
    Map<MuscleGroup, MuscleRecoveryInfo> recoveryStatus = {};

    // 각 근육그룹별 초기화
    for (MuscleGroup muscle in MuscleGroup.values) {
      recoveryStatus[muscle] = MuscleRecoveryInfo(muscle, 0, DateTime.now());
    }

    // 최근 3일간의 운동 데이터 분석
    for (int i = 0; i < 3; i++) {
      DateTime checkDate = DateTime.now().subtract(Duration(days: i));
      List<WorkoutRecord> workouts = _getWorkoutsForDay(checkDate);

      for (WorkoutRecord workout in workouts) {
        MuscleRecoveryInfo current = recoveryStatus[workout.muscleGroup]!;

        // 운동 강도와 경과 시간을 고려한 데미지 계산
        double timeFactor = 1.0 - (i * 0.3); // 시간이 지날수록 회복
        double damage = workout.intensity * timeFactor;

        if (damage > current.damageLevel) {
          recoveryStatus[workout.muscleGroup] = MuscleRecoveryInfo(
            workout.muscleGroup,
            damage,
            checkDate,
          );
        }
      }
    }

    return recoveryStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('운동 기록'),
        backgroundColor: Colors.blue[600],
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // 근육 회복 상태 섹션
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey[900],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.healing, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          '근육 회복 상태',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildMuscleRecoveryView(),
                    SizedBox(height: 16),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 30,
                      color: Colors.grey[400],
                    ),
                    Text(
                      '아래로 스크롤하여 달력 보기',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 달력 섹션
          SliverToBoxAdapter(
            child: Container(
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TableCalendar<WorkoutRecord>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      eventLoader: _getWorkoutsForDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        markerDecoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.blue[600],
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.blue[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                        formatButtonShowsNext: false,
                        formatButtonDecoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        formatButtonTextStyle: TextStyle(color: Colors.white),
                      ),
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        }
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 스크롤 안내 섹션
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 30,
                    color: Colors.grey[600],
                  ),
                  Text(
                    '아래로 스크롤하여 운동 기록 보기',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // 운동 기록 섹션
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey[50],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.fitness_center, color: Colors.blue[600]),
                        SizedBox(width: 8),
                        Text(
                          _selectedDay != null
                              ? '${_selectedDay!.month}월 ${_selectedDay!.day}일 운동 기록'
                              : '오늘의 운동 기록',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildWorkoutList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWorkoutDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[600],
      ),
    );
  }

  Widget _buildMuscleRecoveryView() {
    final recoveryStatus = _getMuscleRecoveryStatus();

    return Container(
      height: 400,
      child: Row(
        children: [
          // 전신 실루엣
          Expanded(
            flex: 2,
            child: Container(
              child: CustomPaint(
                painter: BodyPainter(recoveryStatus),
                child: Container(),
              ),
            ),
          ),
          // 근육별 상세 정보
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '회복 상태',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: MuscleGroup.values.map((muscle) {
                        final info = recoveryStatus[muscle]!;
                        return _buildMuscleInfoCard(info);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleInfoCard(MuscleRecoveryInfo info) {
    Color statusColor = _getRecoveryColor(info.damageLevel);
    String statusText = _getRecoveryText(info.damageLevel);
    int recoveryHours = _getRecoveryHours(info.damageLevel);

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      color: Colors.grey[800],
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getMuscleGroupName(info.muscleGroup),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: info.damageLevel / 10,
              backgroundColor: Colors.grey[600],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
            SizedBox(height: 4),
            Text(
              recoveryHours > 0 ? '회복까지 ${recoveryHours}시간' : '회복 완료',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRecoveryColor(double damageLevel) {
    if (damageLevel < 3) return Colors.green;
    if (damageLevel < 6) return Colors.yellow;
    if (damageLevel < 8) return Colors.orange;
    return Colors.red;
  }

  String _getRecoveryText(double damageLevel) {
    if (damageLevel < 3) return '회복됨';
    if (damageLevel < 6) return '경미한 피로';
    if (damageLevel < 8) return '피로함';
    return '심한 피로';
  }

  int _getRecoveryHours(double damageLevel) {
    if (damageLevel < 3) return 0;
    if (damageLevel < 6) return (damageLevel * 6).round();
    if (damageLevel < 8) return (damageLevel * 8).round();
    return (damageLevel * 10).round();
  }

  String _getMuscleGroupName(MuscleGroup muscle) {
    switch (muscle) {
      case MuscleGroup.chest:
        return '가슴';
      case MuscleGroup.back:
        return '등';
      case MuscleGroup.shoulders:
        return '어깨';
      case MuscleGroup.arms:
        return '팔';
      case MuscleGroup.legs:
        return '다리';
      case MuscleGroup.core:
        return '코어';
      default:
        return '';
    }
  }

  Widget _buildWorkoutList() {
    final workouts = _getWorkoutsForDay(_selectedDay ?? DateTime.now());

    if (workouts.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_gymnastics, size: 60, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                '이 날의 운동 기록이 없습니다',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _showAddWorkoutDialog,
                child: Text('운동 기록 추가'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.fitness_center, color: Colors.blue[600]),
            ),
            title: Text(
              workout.exercise,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${workout.sets} | ${workout.details}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getIntensityColor(workout.intensity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '강도 ${workout.intensity}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  onPressed: () => _deleteWorkout(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getIntensityColor(int intensity) {
    if (intensity <= 3) return Colors.green;
    if (intensity <= 6) return Colors.orange;
    return Colors.red;
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
              title: Text('운동 기록 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: exerciseController,
                      decoration: InputDecoration(
                        labelText: '운동명',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: setsController,
                      decoration: InputDecoration(
                        labelText: '세트 수',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: detailsController,
                      decoration: InputDecoration(
                        labelText: '상세 정보 (무게, 횟수 등)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButton<MuscleGroup>(
                      value: selectedMuscle,
                      isExpanded: true,
                      items: MuscleGroup.values.map((muscle) {
                        return DropdownMenuItem(
                          value: muscle,
                          child: Text(_getMuscleGroupName(muscle)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedMuscle = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
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
                  child: Text('취소'),
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
                  child: Text('추가'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                  ),
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

    setState(() {
      if (_workoutData[selectedDate] == null) {
        _workoutData[selectedDate] = [];
      }
      _workoutData[selectedDate]!.add(
        WorkoutRecord(exercise, sets, details, muscle, intensity),
      );
    });
  }

  void _deleteWorkout(int index) {
    final selectedDate = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    setState(() {
      _workoutData[selectedDate]?.removeAt(index);
    });
  }
}

class WorkoutRecord {
  final String exercise;
  final String sets;
  final String details;
  final MuscleGroup muscleGroup;
  final int intensity; // 1-10 scale

  WorkoutRecord(
    this.exercise,
    this.sets,
    this.details,
    this.muscleGroup,
    this.intensity,
  );
}

enum MuscleGroup { chest, back, shoulders, arms, legs, core }

class MuscleRecoveryInfo {
  final MuscleGroup muscleGroup;
  final double damageLevel; // 0-10 scale
  final DateTime lastWorkoutDate;

  MuscleRecoveryInfo(this.muscleGroup, this.damageLevel, this.lastWorkoutDate);
}

class BodyPainter extends CustomPainter {
  final Map<MuscleGroup, MuscleRecoveryInfo> recoveryStatus;

  BodyPainter(this.recoveryStatus);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double scale = size.width / 200;

    // 머리
    paint.color = Colors.grey[600]!;
    canvas.drawCircle(
      Offset(centerX, centerY - 140 * scale),
      25 * scale,
      paint,
    );

    // 목
    paint.color = Colors.grey[600]!;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY - 110 * scale),
        width: 20 * scale,
        height: 20 * scale,
      ),
      paint,
    );

    // 가슴
    paint.color = _getRecoveryColor(
      recoveryStatus[MuscleGroup.chest]!.damageLevel,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY - 80 * scale),
        width: 80 * scale,
        height: 40 * scale,
      ),
      paint,
    );

    // 어깨
    paint.color = _getRecoveryColor(
      recoveryStatus[MuscleGroup.shoulders]!.damageLevel,
    );
    canvas.drawCircle(
      Offset(centerX - 50 * scale, centerY - 85 * scale),
      20 * scale,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX + 50 * scale, centerY - 85 * scale),
      20 * scale,
      paint,
    );

    // 팔
    paint.color = _getRecoveryColor(
      recoveryStatus[MuscleGroup.arms]!.damageLevel,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX - 65 * scale, centerY - 40 * scale),
        width: 20 * scale,
        height: 60 * scale,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX + 65 * scale, centerY - 40 * scale),
        width: 20 * scale,
        height: 60 * scale,
      ),
      paint,
    );

    // 등/코어 (몸통)
    paint.color = _getRecoveryColor(
      recoveryStatus[MuscleGroup.back]!.damageLevel,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY - 30 * scale),
        width: 80 * scale,
        height: 60 * scale,
      ),
      paint,
    );

    // 코어 (복근 부분)
    paint.color = _getRecoveryColor(
      recoveryStatus[MuscleGroup.core]!.damageLevel,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 10 * scale),
        width: 60 * scale,
        height: 30 * scale,
      ),
      paint,
    );

    // 다리
    paint.color = _getRecoveryColor(
      recoveryStatus[MuscleGroup.legs]!.damageLevel,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX - 20 * scale, centerY + 70 * scale),
        width: 25 * scale,
        height: 80 * scale,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX + 20 * scale, centerY + 70 * scale),
        width: 25 * scale,
        height: 80 * scale,
      ),
      paint,
    );

    // 윤곽선 그리기
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    paint.strokeWidth = 1;

    // 전체 윤곽선을 다시 그리기
    canvas.drawCircle(
      Offset(centerX, centerY - 140 * scale),
      25 * scale,
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY - 110 * scale),
        width: 20 * scale,
        height: 20 * scale,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY - 80 * scale),
        width: 80 * scale,
        height: 40 * scale,
      ),
      paint,
    );
  }

  Color _getRecoveryColor(double damageLevel) {
    if (damageLevel < 3) return Colors.green;
    if (damageLevel < 6) return Colors.yellow;
    if (damageLevel < 8) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
