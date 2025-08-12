// 自定义裁剪器 - 波浪形
import 'package:field_login/style/adapt.dart';
import 'package:flutter/material.dart';

class ToolsBackgroundClipper extends CustomClipper<Path> {
  final double arrowWidth;

  ToolsBackgroundClipper({required this.arrowWidth});

  @override
  Path getClip(Size size) {
    Path path = Path();

    final radius1 = 20.dp;
    final radius2 = 6.dp;

    // 右箭头部分宽度
    final arrowWidth = this.arrowWidth.dp;
    final arrowHeight = 80.dp;

    // 起点左上角
    path.moveTo(0, 0);
    path.lineTo(size.width - arrowWidth - radius1, 0);

    path.quadraticBezierTo(size.width - arrowWidth, 0, size.width - arrowWidth, radius1);

    // 右侧凸起开始 Y
    final startY = (size.height - arrowHeight) * 0.5;
    // 右侧凸起结束时的 Y
    final endY = (size.height + arrowHeight) * 0.5;

    path.lineTo(size.width - arrowWidth, startY);
    path.lineTo(size.width - radius2, startY);

    path.quadraticBezierTo(size.width, startY, size.width, startY + radius2);

    path.lineTo(size.width, endY - radius2);

    path.quadraticBezierTo(size.width, endY, size.width - radius2, endY);

    path.lineTo(size.width - arrowWidth, endY);

    path.lineTo(size.width - arrowWidth, size.height - radius1);

    path.quadraticBezierTo(size.width - arrowWidth, size.height, size.width - arrowWidth - radius1, size.height);

    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
