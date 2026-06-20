import 'dart:math';
import 'package:flutter/material.dart';

class SemiCircularProgress extends StatelessWidget {
  final double percentage;
  final double size;

  const SemiCircularProgress({
    super.key,
    required this.percentage,
    this.size = 130,
  });

  @override
  Widget build(BuildContext context) {
    // Bound percentage between 0 and 100
    final double boundedPercent = percentage.clamp(0.0, 100.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _SemiCircularProgressPainter(
              percentage: boundedPercent,
              primaryColor: Theme.of(context).colorScheme.primary,
              secondaryColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          // Inside Labels Column
          Padding(
            padding: const EdgeInsets.only(top: 10.0), // slightly shift down since arc opens at bottom
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "SCORE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  "${boundedPercent.round()}%",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  boundedPercent >= 86 ? "JOB READY" : "BEGINNER",
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SemiCircularProgressPainter extends CustomPainter {
  final double percentage;
  final Color primaryColor;
  final Color secondaryColor;

  _SemiCircularProgressPainter({
    required this.percentage,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 8.0;
    final double halfWidth = size.width / 2;
    final double halfHeight = size.height / 2;
    final Offset center = Offset(halfWidth, halfHeight);
    final double radius = halfWidth - (strokeWidth / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // Config angles: 135 degrees (0.75 * pi) to 405 degrees (2.25 * pi)
    final double startAngle = 0.75 * pi;
    final double totalSweep = 1.5 * pi; // 270 degrees sweep
    final double progressSweep = (percentage / 100.0) * totalSweep;

    // 1. Draw Background Track Arc
    final Paint trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, totalSweep, false, trackPaint);

    // 2. Draw Progress Arc with Linear Gradient
    if (percentage > 0) {
      final Paint progressPaint = Paint()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF00F2FE), // Bright Cyan
            primaryColor,          // Theme primary (Indigo)
            secondaryColor,        // Theme secondary (Purple)
            const Color(0xFFEC4899), // Hot Pink
          ],
        ).createShader(rect);

      canvas.drawArc(rect, startAngle, progressSweep, false, progressPaint);

      // 3. Draw Glowing Thumb/Dot at the tip of progress
      final double endAngle = startAngle + progressSweep;
      final double thumbX = center.dx + radius * cos(endAngle);
      final double thumbY = center.dy + radius * sin(endAngle);
      final Offset thumbOffset = Offset(thumbX, thumbY);

      // Thumb Outer Glow Halo
      final Paint glowPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(thumbOffset, 9, glowPaint);

      // Thumb Outer Ring
      final Paint outerRingPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(thumbOffset, 6, outerRingPaint);

      // Thumb Inner solid white dot
      final Paint innerDotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(thumbOffset, 3.5, innerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SemiCircularProgressPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
