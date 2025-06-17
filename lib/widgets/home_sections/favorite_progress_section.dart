import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../simple_line_chart.dart';

import '../../providers/exercise_presets.dart';
import '../../providers/workout_data.dart';
import '../../providers/order_provider.dart';

class FavoriteProgressSection extends StatelessWidget {
  final VoidCallback? onScrollDown;

  const FavoriteProgressSection({super.key, this.onScrollDown});

  @override
  Widget build(BuildContext context) {
    final presets = Provider.of<ExercisePresets>(context);
    final data = Provider.of<WorkoutData>(context);
    final order = Provider.of<OrderProvider>(context);
    final favorites = presets.presets
        .where((p) => presets.isFavorite(p))
        .toList();
    favorites.sort((a, b) {
      final list = order.favoriteOrder;
      final ia = list.indexOf(a);
      final ib = list.indexOf(b);
      if (ia == -1 && ib == -1) return 0;
      if (ia == -1) return 1;
      if (ib == -1) return -1;
      return ia.compareTo(ib);
    });

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
                onReorder: (oldIndex, newIndex) =>
                    order.reorderFavoriteList(favorites, oldIndex, newIndex),
                children: [
                  for (final e in favorites)
                    Container(
                      key: ValueKey(e),
                      child: _buildItem(context, e, data),
                    )
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
          final doneSets = r.setDetails.where((s) => s.done).toList();
          if (doneSets.isNotEmpty) {
            w = doneSets.first.weight;
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
          final doneSets = r.setDetails.where((s) => s.done).toList();
          if (doneSets.isNotEmpty) {
            w = doneSets.first.weight;
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
