import 'package:flutter/material.dart';
import '../models/workout.dart';

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
