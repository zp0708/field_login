import 'package:flutter/material.dart';
import './tab_painter.dart';

class TabLeftPainter extends TabPainter {
  const TabLeftPainter({
    super.shapeWidth,
    super.top,
    super.cornerRadius,
    super.color,
  });

  // 绘制标签形状的 Painter
  @override
  void paint(Canvas canvas, Size size) {
    // 创建红色画笔
    final paintLeft = Paint()..color = Colors.white;

    // 构建左侧路径
    final pathLeft = Path();
    final width = size.width;

    // 从左下角开始
    pathLeft.moveTo(0, size.height);
    // 画到左侧上方
    pathLeft.lineTo(0, cornerRadius);
    // 左上圆角
    pathLeft.quadraticBezierTo(0, 0, cornerRadius, 0); // 左上圆角
    // 画到中间连接弧的起点
    pathLeft.lineTo(width - shapeWidth, 0);
    final x1 = width - shapeWidth + 50;
    // 中间连接弧
    pathLeft.cubicTo(x1, 0, width - 50, size.height, width, size.height); // 中间连接弧
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
