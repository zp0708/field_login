import 'package:flutter/material.dart';
import '../image_carousel_controller.dart';
import '../carousel_indicator.dart';

/// 指示器覆盖层组件
class IndicatorOverlay extends StatelessWidget {
  final ImageCarouselController controller;
  final CarouselIndicatorType type;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final bool enableAnimation;
  final Duration animationDuration;
  final VoidCallback? onIndicatorTap;

  const IndicatorOverlay({
    super.key,
    required this.controller,
    this.type = CarouselIndicatorType.dots,
    this.activeColor,
    this.inactiveColor,
    this.size,
    this.padding,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onIndicatorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Center(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            return CarouselIndicator(
              currentIndex: controller.currentIndex,
              totalCount: controller.totalCount,
              type: type,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              size: size,
              padding: padding,
              enableAnimation: enableAnimation,
              animationDuration: animationDuration,
              onIndicatorTap: onIndicatorTap,
            );
          },
        ),
      ),
    );
  }
} 