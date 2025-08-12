import 'package:field_login/style/adapt.dart';
import 'package:flutter/material.dart';

class ShareBackgroundClipper extends CustomClipper<Path> {
  final double arrowWidth;

  ShareBackgroundClipper({required this.arrowWidth});

  @override
  Path getClip(Size size) {
    final centerX = size.width / 2;
    final bumpWidth = 30.0.dp;

    final left = centerX - bumpWidth / 2;
    final right = centerX + bumpWidth / 2;

    final top = 10.0.dp;
    final cornerRadius = 10.0.dp;

    // 构建背景
    final path = Path();

    // 画到左侧上方
    path.moveTo(0, cornerRadius);
    // 左上圆角
    path.quadraticBezierTo(0, 0, cornerRadius, 0); // 左上圆角
    // 画到中间连接弧的起点

    // 左侧直线 → 凸起左边开始
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius); // 左上圆角
    path.lineTo(size.width, size.height - top - cornerRadius);

    path.quadraticBezierTo(size.width, size.height - top, size.width - cornerRadius, size.height - top); // 左上圆角

    path.lineTo(right, size.height - top);

    path.cubicTo(
      right - 10, size.height - top, // 控制点 1
      centerX + 5, size.height, // 控制点 2
      centerX, size.height, // 顶部
    );

    path.cubicTo(
      centerX - 10, size.height - top, // 控制点 1
      left + 5, size.height - top, // 控制点 2
      left, size.height - top, // 回到底线
    );

    path.lineTo(cornerRadius, size.height - top);

    path.quadraticBezierTo(0, size.height - top, 0, size.height - top - cornerRadius);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
