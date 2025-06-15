import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exercise_presets.dart';
import '../../providers/workout_data.dart';

class FavoriteProgressSection extends StatelessWidget {
  const FavoriteProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final presets = Provider.of<ExercisePresets>(context);
    final data = Provider.of<WorkoutData>(context);
    final favorites = presets.presets
        .where((p) => presets.isFavorite(p))
        .toList();

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
            child: ListView(
              children: favorites
                  .map((e) => _buildItem(context, e, data))
                  .toList(),
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

    return ListTile(
      title: Text(exercise),
      trailing: Text(text),
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
            w = r.setDetails.first.weight;
          } else {
            final m = RegExp(r'(\d+(?:\.\d+)?)kg').firstMatch(r.details);
            if (m != null) w = double.tryParse(m.group(1)!);
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
}
