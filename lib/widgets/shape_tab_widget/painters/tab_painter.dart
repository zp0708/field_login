import 'package:flutter/material.dart';

class TabPainter extends CustomPainter {
  final double shapeWidth;
  final double top;
  final double cornerRadius;
  final Color color;

  const TabPainter({
    this.shapeWidth = 80,
    this.top = 4,
    this.cornerRadius = 20,
    this.color = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    throw UnimplementedError();
  }
}
