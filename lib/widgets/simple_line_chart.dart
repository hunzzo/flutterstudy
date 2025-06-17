import 'package:flutter/material.dart';
import 'dart:math';

class SimpleLineChart extends StatelessWidget {
  final List<double> values;
  final double? minY;
  final double? maxY;
  final double height;

  const SimpleLineChart({
    super.key,
    required this.values,
    this.minY,
    this.maxY,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _LineChartPainter(values, minY, maxY),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double minY;
  final double maxY;

  _LineChartPainter(this.values, double? minY, double? maxY)
      : minY = minY ?? (values.isEmpty ? 0 : values.reduce(min)),
        maxY = maxY ?? (values.isEmpty ? 0 : values.reduce(max));

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final stepX = size.width / (values.length - 1);
    final range = max(1e-6, maxY - minY);

    Path path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = stepX * i;
      final y = size.height * (1 - (values[i] - minY) / range);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY;
  }
}
