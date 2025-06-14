import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/workout.dart';
import '../../providers/workout_data.dart';
import '../body_painter.dart';
import 'favorite_progress_section.dart';

class MuscleRecoverySection extends StatefulWidget {
  const MuscleRecoverySection({super.key});

  @override
  State<MuscleRecoverySection> createState() => _MuscleRecoverySectionState();
}

class _MuscleRecoverySectionState extends State<MuscleRecoverySection> {
  final PageController _controller = PageController();

  List<WorkoutRecord> _getWorkoutsForDay(BuildContext context, DateTime day) {
    final provider = Provider.of<WorkoutData>(context, listen: false);
    return provider.workoutsForDay(day);
  }

  Map<MuscleGroup, MuscleRecoveryInfo> _getMuscleRecoveryStatus(
      BuildContext context) {
    Map<MuscleGroup, MuscleRecoveryInfo> recoveryStatus = {};

    for (MuscleGroup muscle in MuscleGroup.values) {
      recoveryStatus[muscle] = MuscleRecoveryInfo(muscle, 0, DateTime.now());
    }

    for (int i = 0; i < 3; i++) {
      DateTime checkDate = DateTime.now().subtract(Duration(days: i));
      List<WorkoutRecord> workouts = _getWorkoutsForDay(context, checkDate);

      for (WorkoutRecord workout in workouts) {
        MuscleRecoveryInfo current = recoveryStatus[workout.muscleGroup]!;

        double timeFactor = 1.0 - (i * 0.3);
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
    return PageView(
      controller: _controller,
      children: [
        _buildRecoveryContent(context),
        const FavoriteProgressSection(),
      ],
    );
  }

  Widget _buildRecoveryContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recoveryStatus = _getMuscleRecoveryStatus(context);
    return Container(
      color: isDark ? Colors.grey[900] : Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.healing,
                  color: Theme.of(context).textTheme.titleLarge?.color),
              const SizedBox(width: 8),
              Text(
                '근육 회복 상태',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMuscleRecoveryView(context, recoveryStatus, isDark),
        ],
      ),
    );
  }

  Widget _buildMuscleRecoveryView(
      BuildContext context,
      Map<MuscleGroup, MuscleRecoveryInfo> recoveryStatus,
      bool isDark) {

    return SizedBox(
      height: 400,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CustomPaint(
              painter: BodyPainter(recoveryStatus),
              child: Container(),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    '회복 상태',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium

                        ?.copyWith(fontWeight: FontWeight.bold),

                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: MuscleGroup.values
                          .map((muscle) => _buildMuscleInfoCard(
                              context, recoveryStatus[muscle]!, isDark))

                          .toList(),
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


  Widget _buildMuscleInfoCard(
      BuildContext context, MuscleRecoveryInfo info, bool isDark) {

    Color statusColor = _getRecoveryColor(info.damageLevel);
    String statusText = _getRecoveryText(info.damageLevel);
    int recoveryHours = _getRecoveryHours(info.damageLevel);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? Colors.grey[800] : Colors.white,

      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getMuscleGroupName(info.muscleGroup),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: info.damageLevel / 10,

              backgroundColor: isDark ? Colors.grey[600] : Colors.grey[300],

              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
            const SizedBox(height: 4),
            Text(
              recoveryHours > 0 ? '회복까지 $recoveryHours시간' : '회복 완료',
              style: Theme.of(context).textTheme.bodySmall,
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
    }
  }
}
