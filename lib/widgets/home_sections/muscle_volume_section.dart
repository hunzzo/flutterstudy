import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/workout.dart';
import '../../providers/workout_data.dart';
import '../simple_line_chart.dart';

class MuscleVolumeSection extends StatelessWidget {
  const MuscleVolumeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<WorkoutData>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? Colors.grey[900] : Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics,
                  color: Theme.of(context).textTheme.titleLarge?.color),
              const SizedBox(width: 8),
              Text(
                '근육별 최근 기록',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: MuscleGroup.values
                  .map((g) => _buildItem(context, g, data))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, MuscleGroup group, WorkoutData data) {
    final history = _volumeHistory(data, group);
    final lastDate = history.isNotEmpty ? history.last.key : null;
    final diff = history.length >= 2
        ? history.last.value - history[history.length - 2].value
        : null;
    final days = lastDate != null
        ? DateTime.now().difference(lastDate).inDays
        : null;
    String subtitle = '';
    if (days != null) {
      subtitle += '$days일 전 · ';
    }
    if (diff != null) {
      subtitle +=
          diff > 0 ? '+${diff.toStringAsFixed(1)}' : diff.toStringAsFixed(1);
    }

    final values = history.map((e) => e.value).toList();

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
                  _groupName(group),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(subtitle),
              ],
            ),
            const SizedBox(height: 8),
            if (values.length > 1)
              SimpleLineChart(
                values: values.length > 7
                    ? values.sublist(values.length - 7)
                    : values,
                height: 80,
              ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<DateTime, double>> _volumeHistory(
      WorkoutData data, MuscleGroup group) {
    List<MapEntry<DateTime, double>> list = [];
    data.allWorkoutData.forEach((date, records) {
      double volume = 0;
      for (final r in records) {
        if (r.muscleGroup == group) {
          for (final s in r.setDetails) {
            volume += s.weight * s.reps;
          }
        }
      }
      if (volume > 0) {
        list.add(MapEntry(date, volume));
      }
    });
    list.sort((a, b) => a.key.compareTo(b.key));
    return list;
  }

  String _groupName(MuscleGroup g) {
    switch (g) {
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
    }
  }
}
