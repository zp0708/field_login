import './tab_painter.dart';
import 'package:flutter/material.dart';

class TabBackgroundPainter extends TabPainter {
  // 背景色向下延伸，处理下方组件有圆角的情况
  final double extendBottom;

  const TabBackgroundPainter({
    super.shapeWidth,
    super.top,
    super.cornerRadius,
    super.color,
    this.extendBottom = 0,
  });

  // 绘制标签形状的 Painter
  @override
  void paint(Canvas canvas, Size size) {
    // 构建背景
    final bgPaint = Paint()..color = color;
    final bg = Path();

    // 从左下角开始
    bg.moveTo(top, size.height + extendBottom);
    // 画到左侧上方
    bg.lineTo(top, cornerRadius);
    // 左上圆角
    bg.quadraticBezierTo(top, top, cornerRadius, top); // 左上圆角
    // 画到中间连接弧的起点
    bg.lineTo(size.width - cornerRadius - top, top);

    // 右侧圆弧
    bg.quadraticBezierTo(size.width - top, top, size.width - top, cornerRadius + top); // 左上圆角
    // 画到底部中间
    bg.lineTo(size.width - top, size.height + extendBottom);
    bg.close();

    // 绘制路径
    canvas.drawPath(bg, bgPaint);
  }

  @override
  // 通常不需要重绘
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
