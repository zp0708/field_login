import './tab_painter.dart';
import 'package:flutter/material.dart';

class TabRightPainter extends TabPainter {
  const TabRightPainter({
    super.shapeWidth,
    super.top,
    super.cornerRadius,
    super.color,
  });

  // 绘制标签形状的 Painter
  @override
  void paint(Canvas canvas, Size size) {
    // 创建红色画笔
    final paintLeft = Paint()..color = color;

    // 构建左侧路径
    final pathLeft = Path();
    final width = size.width;

    // 从左下角开始
    pathLeft.moveTo(0, size.height);

    // (x3,y3)
    pathLeft.cubicTo(50, size.height, shapeWidth - 50, 0, shapeWidth, 0);

    // 画到左侧上方
    pathLeft.lineTo(size.width - cornerRadius, 0);
    // 右上圆角
    pathLeft.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    // 画到底部中间
    pathLeft.lineTo(width, size.height);
    pathLeft.close();

    // 绘制路径
    canvas.drawPath(pathLeft, paintLeft);
  }

  @override
  // 通常不需要重绘
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
