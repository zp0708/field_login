import 'package:flutter/material.dart';

/// 右侧半透明半圆组件 - 最简版本
class RightSemiCircle extends StatelessWidget {
  final double width;
  final double height;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderWidth;
  final double opacity;
  final Widget? child;

  const RightSemiCircle({
    super.key,
    this.width = 200,
    this.height = 400,
    this.fillColor,
    this.borderColor,
    this.borderWidth,
    this.opacity = 0.3,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: (fillColor ?? Colors.white).withOpacity(opacity),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(150),
            bottomLeft: Radius.circular(150),
          ),
          border: borderColor != null
              ? Border.all(
                  color: borderColor!.withOpacity(opacity * 2),
                  width: borderWidth ?? 2,
                )
              : null,
        ),
        child: child,
      ),
    );
  }
}

class LeftSemiCircleMenuDemo extends StatelessWidget {
  const LeftSemiCircleMenuDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('右侧半透明半圆'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey.shade200,
        child: Stack(
          children: [
            // 背景内容
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '屏幕背景内容',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '右侧有一个半透明的半圆',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // 右侧半透明半圆 - 最简版本
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: RightSemiCircle(
                  width: 300,
                  height: 600,
                  fillColor: Colors.red,
                  borderColor: Colors.red,
                  opacity: 0.8,
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 100),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            '菜单',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
