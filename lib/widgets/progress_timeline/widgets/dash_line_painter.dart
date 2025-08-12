import 'package:flutter/material.dart';

/// 虚线绘制器
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    this.dashWidth = 4,
    this.dashSpace = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;

    final totalWidth = size.width;
    final dashLength = dashWidth + dashSpace;
    final dashCount = (totalWidth / dashLength).floor();
    final remainingWidth = totalWidth - (dashCount * dashLength);

    for (int i = 0; i < dashCount; i++) {
      final startX = i * dashLength;
      final endX = startX + dashWidth;
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(endX, size.height / 2),
        paint,
      );
    }

    // 绘制剩余的虚线
    if (remainingWidth > dashWidth) {
      final startX = dashCount * dashLength;
      final endX = startX + dashWidth;
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(endX, size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
