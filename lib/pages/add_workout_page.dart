import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/exercise_presets.dart';
import '../providers/workout_data.dart';
import '../models/workout.dart';

class AddWorkoutPage extends StatefulWidget {
  final DateTime selectedDate;
  const AddWorkoutPage({super.key, required this.selectedDate});

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final List<String> _queue = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  MuscleGroup? _selectedGroup;
  bool _showFavoritesOnly = false;
  bool _sortByFrequency = false;

  @override
  Widget build(BuildContext context) {
    final presetProvider = context.watch<ExercisePresets>();
    final workoutData = context.watch<WorkoutData>();
    List<String> presets = presetProvider.presets;

    List<String> exercises = presets
        .where((e) => e.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (_selectedGroup != null) {
      exercises = exercises
          .where((e) =>
              presetProvider.muscleGroupFor(e) == _selectedGroup)
          .toList();
    }

    if (_showFavoritesOnly) {
      exercises =
          exercises.where((e) => presetProvider.isFavorite(e)).toList();
    }

    if (_sortByFrequency) {
      exercises.sort((a, b) =>
          workoutData.exerciseCount(b).compareTo(
                workoutData.exerciseCount(a),
              ));
    } else {
      exercises.sort();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 선택'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('추가', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 80,
            child: ReorderableListView(
              scrollDirection: Axis.horizontal,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _queue.removeAt(oldIndex);
                  _queue.insert(newIndex, item);
                });
              },
              children: [
                for (final ex in _queue)
                  Padding(
                    key: ValueKey(ex),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Chip(
                      label: Text(ex),
                      onDeleted: () {
                        setState(() {
                          _queue.remove(ex);
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '운동 검색',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                DropdownButton<MuscleGroup?>(
                  value: _selectedGroup,
                  hint: const Text('부위'),
                  onChanged: (val) => setState(() => _selectedGroup = val),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('전체')),
                    ...MuscleGroup.values.map(
                      (g) => DropdownMenuItem(
                        value: g,
                        child: Text(g.name),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _showFavoritesOnly ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () =>
                      setState(() => _showFavoritesOnly = !_showFavoritesOnly),
                ),
                const SizedBox(width: 8),
                DropdownButton<bool>(
                  value: _sortByFrequency,
                  onChanged: (val) =>
                      setState(() => _sortByFrequency = val ?? false),
                  items: const [
                    DropdownMenuItem(
                        value: false, child: Text('이름순')),
                    DropdownMenuItem(value: true, child: Text('빈도순')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.1,
              ),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                final isFav = presetProvider.isFavorite(exercise);
                final freq = workoutData.exerciseCount(exercise);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _queue.add(exercise);
                    });
                  },
                  child: Card(
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.fitness_center, size: 32),
                              const SizedBox(height: 8),
                              Text(exercise,
                                  textAlign: TextAlign.center,
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold)),
                              Text('횟수 $freq',
                                  style:
                                      Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: Icon(
                              isFav ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () =>
                                presetProvider.toggleFavorite(exercise),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    final provider = context.read<WorkoutData>();
    for (final ex in _queue) {
      final last = provider.latestRecordForExercise(ex);
      if (last != null) {
        provider.addWorkout(
          widget.selectedDate,
          WorkoutRecord(
            ex,
            last.sets,
            last.details,
            last.muscleGroup,
            last.intensity,
          ),
        );
      } else {
        provider.addWorkout(
          widget.selectedDate,
          WorkoutRecord(ex, '', '', MuscleGroup.chest),
        );
      }
    }
    Navigator.pop(context);
  }
}
