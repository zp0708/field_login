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
    final centerY = size.height * 0.5;

    // 起点左上角
    path.moveTo(0, 0);
    path.lineTo(size.width - arrowWidth - radius1, 0);

    path.quadraticBezierTo(size.width - arrowWidth, 0, size.width - arrowWidth, radius1);
    path.lineTo(size.width - arrowWidth, centerY - arrowHeight * 0.5);
    path.lineTo(size.width - radius2, centerY - arrowHeight * 0.5);

    path.quadraticBezierTo(size.width, centerY - arrowHeight * 0.5, size.width, centerY - arrowHeight * 0.5 + radius2);

    path.lineTo(size.width, centerY + arrowHeight * 0.5 - radius2);

    path.quadraticBezierTo(size.width, centerY + arrowHeight * 0.5, size.width - radius2, centerY + arrowHeight * 0.5);

    path.lineTo(size.width - arrowWidth, centerY + arrowHeight * 0.5);

    path.lineTo(size.width - arrowWidth, size.height - radius1);

    path.quadraticBezierTo(size.width - arrowWidth, size.height, size.width - arrowWidth - radius1, size.height);

    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
