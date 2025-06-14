import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/workout.dart';
import '../widgets/home_sections/muscle_recovery_section.dart';
import '../widgets/home_sections/calendar_section.dart';
import '../widgets/home_sections/scroll_hint_section.dart';
import '../widgets/home_sections/workout_log_section.dart';
import 'settings_page.dart';
import '../providers/workout_data.dart';
import '../providers/exercise_presets.dart';
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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _recoveryKey = GlobalKey();
  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _hintKey = GlobalKey();
  final GlobalKey _logKey = GlobalKey();
  List<double> _sectionOffsets = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateOffsets());
  }

  void _updateOffsets() {
    _sectionOffsets = [];
    double offset = 0;
    final contexts = [
      _recoveryKey.currentContext,
      _calendarKey.currentContext,
      _hintKey.currentContext,
      _logKey.currentContext,
    ];
    for (final ctx in contexts) {
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox;
      _sectionOffsets.add(offset);
      offset += box.size.height;
    }
  }

  void _snapScroll() {
    if (_sectionOffsets.isEmpty) return;
    final current = _scrollController.offset;
    double target = _sectionOffsets.first;
    double diff = (current - target).abs();
    for (final o in _sectionOffsets) {
      final d = (current - o).abs();
      if (d < diff) {
        diff = d;
        target = o;
      }
    }
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
      body: NotificationListener<ScrollEndNotification>(
        onNotification: (notification) {
          _updateOffsets();
          _snapScroll();
          return false;
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: MuscleRecoverySection(key: _recoveryKey),
            ),
            SliverToBoxAdapter(
              child: CalendarSection(
                key: _calendarKey,
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
            SliverToBoxAdapter(
              child: ScrollHintSection(key: _hintKey),
            ),
            SliverToBoxAdapter(
              child: WorkoutLogSection(
                key: _logKey,
                selectedDay: _selectedDay,
                onAddWorkout: _showAddWorkoutDialog,
                onDeleteWorkout: _deleteWorkout,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWorkoutDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
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
    final presetsProvider = Provider.of<ExercisePresets>(context, listen: false);

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
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return presetsProvider.presets.where((String option) {
                          return option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        exerciseController.text = textEditingController.text;
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: '운동명',
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                      onSelected: (selection) {
                        exerciseController.text = selection;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          if (exerciseController.text.isNotEmpty) {
                            presetsProvider.addPreset(exerciseController.text);
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('프리셋에 저장'),
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

                  style:
                      ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),

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
