import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class IrregularGradientCard extends StatelessWidget {
  const IrregularGradientCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        // ==========================================
        // 1. ClipPath 提到最外层，充当绝对的边界
        // ==========================================
        child: ClipPath(
          clipper: BottomArcClipper(
            topRadius: 24.0,
            bottomOffset: 40.0,
            cornerCurve: 30.0,
          ),
          child: SizedBox(
            height: 300,
            width: double.infinity,
            // 2. 在裁切好的安全区域内，随意堆叠图层
            child: Stack(
              children: [
                // 图层 A：底部的两个精准渐变圆
                // 由于被 ClipPath 包裹，圆心在左上和右上，但超出边界的部分会自动消失
                Positioned.fill(
                  child: CustomPaint(
                    painter: DualRadialGradientPainter(),
                  ),
                ),

                // 图层 B：全区域的高斯模糊（毛玻璃效果）
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child: Container(
                      color: Colors.white10, // 叠加一层微弱的白底提升质感
                    ),
                  ),
                ),

                // 图层 C：最上层的真实内容
                const Positioned.fill(
                  child: Center(
                    child: Text(
                      '绝不溢出的不规则卡片',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DualRadialGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // ==========================================
    // 1. 绘制左上角，半径 100 的圆形渐变
    // ==========================================
    final Offset center1 = const Offset(0, 0); // 左上角圆心
    const double radius1 = 200.0;

    final paint1 = Paint()
      ..shader = ui.Gradient.radial(
        center1,
        radius1,
        [
          Colors.blueAccent.withValues(alpha: 0.8), // 中心颜色
          Colors.blueAccent.withValues(alpha: 0.0), // 边缘透明，自然融入背景
        ],
      );
    // 只画出半径 100 的圆的区域
    canvas.drawCircle(center1, radius1, paint1);

    // ==========================================
    // 2. 绘制右上角，半径 200 的圆形渐变
    // ==========================================
    final Offset center2 = Offset(size.width, 0); // 右上角圆心
    const double radius2 = 400.0;

    final paint2 = Paint()
      ..shader = ui.Gradient.radial(
        center2,
        radius2,
        [
          Colors.purpleAccent.withValues(alpha: 0.6), // 中心颜色
          Colors.purpleAccent.withValues(alpha: 0.0), // 边缘透明
        ],
      );
    canvas.drawCircle(center2, radius2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // 静态背景无需重绘
}

class BottomArcClipper extends CustomClipper<Path> {
  final double topRadius; // 顶部常规圆角大小
  final double bottomOffset; // 底部大圆弧凸起的高度
  final double cornerCurve; // 底部两侧圆角过渡的平滑度

  BottomArcClipper({
    this.topRadius = 24.0,
    this.bottomOffset = 40.0,
    this.cornerCurve = 30.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // 1. 从左上角圆角的起点开始
    path.moveTo(0, topRadius);

    // 2. 左上角常规圆角
    path.quadraticBezierTo(0, 0, topRadius, 0);

    // 3. 顶部直线到右上角
    path.lineTo(w - topRadius, 0);

    // 4. 右上角常规圆角
    path.quadraticBezierTo(w, 0, w, topRadius);

    // 5. 右侧边向下，停在准备进行底部圆角过渡的地方
    path.lineTo(w, h - bottomOffset - cornerCurve);

    // 6. 右下角过渡圆弧（将垂直向下的线条，平滑过渡到向内弯曲的大圆弧起点）
    path.quadraticBezierTo(
      w,
      h - bottomOffset,
      w - cornerCurve,
      h - bottomOffset + (cornerCurve / 3),
    );

    // 7. 底部中心的大圆弧（连接右下角和左下角的过渡点）
    path.quadraticBezierTo(
      w / 2,
      h,
      cornerCurve,
      h - bottomOffset + (cornerCurve / 3),
    );

    // 8. 左下角过渡圆弧（将大圆弧平滑过渡回左侧垂直线）
    path.quadraticBezierTo(
      0,
      h - bottomOffset,
      0,
      h - bottomOffset - cornerCurve,
    );

    // 9. 闭合路径（回到左上角起点）
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true; // 视需求优化
}
