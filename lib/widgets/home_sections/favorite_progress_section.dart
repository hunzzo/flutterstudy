import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../simple_line_chart.dart';

import '../../providers/exercise_presets.dart';
import '../../providers/workout_data.dart';

class FavoriteProgressSection extends StatefulWidget {
  final VoidCallback? onScrollDown;

  const FavoriteProgressSection({super.key, this.onScrollDown});

  @override
  State<FavoriteProgressSection> createState() => _FavoriteProgressSectionState();
}

class _FavoriteProgressSectionState extends State<FavoriteProgressSection> {
  List<String> _order = [];

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favoriteProgressOrder');
    if (saved != null) {
      setState(() {
        _order = saved;
      });
    }
  }

  Future<void> _saveOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteProgressOrder', _order);
  }

  @override
  Widget build(BuildContext context) {
    final presets = Provider.of<ExercisePresets>(context);
    final data = Provider.of<WorkoutData>(context);
    final favorites = presets.presets
        .where((p) => presets.isFavorite(p))
        .toList();

    // Ensure local order list matches current favorites
    List<String> ordered = _order.where(favorites.contains).toList();
    for (final f in favorites) {
      if (!ordered.contains(f)) ordered.add(f);
    }
    if (!listEquals(ordered, _order)) {
      _order = ordered;
      _saveOrder();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? Colors.grey[900] : Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up,
                  color: Theme.of(context).textTheme.titleLarge?.color),
              const SizedBox(width: 8),
              Text(
                '즐겨찾기 무게 추세',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent &&
                    notification is OverscrollNotification &&
                    notification.overscroll > 0) {
                  onScrollDown?.call();
                }
                return false;
              },
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _order.removeAt(oldIndex);
                    _order.insert(newIndex, item);
                  });
                  _saveOrder();
                },
                children: [
                  for (final ex in _order)
                    Padding(
                      key: ValueKey(ex),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildItem(context, ex, data),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String exercise, WorkoutData data) {
    final diff = _weightTrend(data, exercise);
    String text;
    if (diff == null) {
      text = '-';
    } else if (diff > 0) {
      text = '+${diff.toStringAsFixed(1)}kg';
    } else if (diff < 0) {
      text = '${diff.toStringAsFixed(1)}kg';
    } else {
      text = '변화 없음';
    }

    final weights = _weightHistory(data, exercise);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  exercise,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(text),
              ],
            ),
            const SizedBox(height: 8),
            if (weights.length > 1)
              SimpleLineChart(
                values: weights,
                height: 80,
              ),
          ],
        ),
      ),
    );
  }

  double? _weightTrend(WorkoutData data, String exercise) {
    final map = data.allWorkoutData;
    List<MapEntry<DateTime, double>> list = [];
    map.forEach((date, records) {
      for (final r in records) {
        if (r.exercise == exercise) {
          double? w;
          if (r.setDetails.isNotEmpty) {
            final doneSet = r.setDetails.firstWhere(
              (s) => s.done,
              orElse: () => r.setDetails.first,
            );
            if (doneSet.done) {
              w = doneSet.weight;
            }
          }
          if (w != null) {
            list.add(MapEntry(date, w));
          }
        }
      }
    });
    list.sort((a, b) => a.key.compareTo(b.key));
    if (list.length < 2) return null;
    return list.last.value - list[list.length - 2].value;
  }

  List<double> _weightHistory(WorkoutData data, String exercise) {
    final map = data.allWorkoutData;
    List<MapEntry<DateTime, double>> list = [];
    map.forEach((date, records) {
      for (final r in records) {
        if (r.exercise == exercise) {
          double? w;
          if (r.setDetails.isNotEmpty) {
            final doneSet = r.setDetails.firstWhere(
              (s) => s.done,
              orElse: () => r.setDetails.first,
            );
            if (doneSet.done) {
              w = doneSet.weight;
            }
          }
          if (w != null) {
            list.add(MapEntry(date, w));
          }
        }
      }
    });
    list.sort((a, b) => a.key.compareTo(b.key));
    final values = list.map((e) => e.value).toList();
    if (values.length > 7) {
      return values.sublist(values.length - 7);
    }
    return values;
  }
}
