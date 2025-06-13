import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/workout.dart';
import '../../providers/workout_data.dart';
import '../body_painter.dart';

class MuscleRecoverySection extends StatelessWidget {
  const MuscleRecoverySection({super.key});

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
    final recoveryStatus = _getMuscleRecoveryStatus(context);
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: const [
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
          const SizedBox(height: 16),
          _buildMuscleRecoveryView(recoveryStatus),
          const SizedBox(height: 16),
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
    );
  }

  Widget _buildMuscleRecoveryView(
      Map<MuscleGroup, MuscleRecoveryInfo> recoveryStatus) {
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
                  const Text(
                    '회복 상태',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: MuscleGroup.values
                          .map((muscle) => _buildMuscleInfoCard(
                              recoveryStatus[muscle]!))
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

  Widget _buildMuscleInfoCard(MuscleRecoveryInfo info) {
    Color statusColor = _getRecoveryColor(info.damageLevel);
    String statusText = _getRecoveryText(info.damageLevel);
    int recoveryHours = _getRecoveryHours(info.damageLevel);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[800],
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
              backgroundColor: Colors.grey[600],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
            const SizedBox(height: 4),
            Text(
              recoveryHours > 0 ? '회복까지 ${recoveryHours}시간' : '회복 완료',
              style: const TextStyle(color: Colors.grey[400], fontSize: 12),
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
}
