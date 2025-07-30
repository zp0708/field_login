import './tab_painter.dart';
import 'package:flutter/material.dart';

class TabCenterPainter extends TabPainter {
  const TabCenterPainter({
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

    // 画到右侧上方
    pathLeft.lineTo(size.width - shapeWidth, 0);

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
