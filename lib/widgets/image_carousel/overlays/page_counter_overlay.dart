import 'package:flutter/material.dart';
import '../image_carousel_controller.dart';

/// 页码显示覆盖层组件
class PageCounterOverlay extends StatelessWidget {
  final ImageCarouselController controller;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final String separator;
  final bool showTotal;
  final String Function(int current, int total)? formatter;

  const PageCounterOverlay({
    super.key,
    required this.controller,
    this.textStyle,
    this.backgroundColor,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    this.separator = ' / ',
    this.showTotal = true,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      right: 10,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          final currentIndex = controller.currentIndex + 1;
          final totalCount = controller.totalCount;
          
          String text;
          if (formatter != null) {
            text = formatter!(currentIndex, totalCount);
          } else if (showTotal) {
            text = '$currentIndex$separator$totalCount';
          } else {
            text = '$currentIndex';
          }

          return Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? Color.fromRGBO(0, 0, 0, 0.5),
              borderRadius: borderRadius ?? BorderRadius.circular(20),
            ),
            child: Text(
              text,
              style: textStyle ?? const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
} 