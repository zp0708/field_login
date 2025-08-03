import 'package:flutter/material.dart';

/// 轮播指示器类型
enum CarouselIndicatorType {
  dots,      // 圆点
  numbers,   // 数字
  lines,     // 线条
}

/// 轮播指示器组件
class CarouselIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final CarouselIndicatorType type;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onIndicatorTap;

  const CarouselIndicator({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    this.type = CarouselIndicatorType.dots,
    this.activeColor,
    this.inactiveColor,
    this.size,
    this.padding,
    this.onIndicatorTap,
  });

  @override
  Widget build(BuildContext context) {
    if (totalCount <= 1) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final activeColor = this.activeColor ?? theme.primaryColor;
    final inactiveColor = this.inactiveColor ?? theme.disabledColor;
    final size = this.size ?? 8.0;

    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalCount, (index) {
          final isActive = index == currentIndex;
          
          switch (type) {
            case CarouselIndicatorType.dots:
              return _buildDotIndicator(
                index: index,
                isActive: isActive,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                size: size,
              );
            case CarouselIndicatorType.numbers:
              return _buildNumberIndicator(
                index: index,
                isActive: isActive,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                size: size,
              );
            case CarouselIndicatorType.lines:
              return _buildLineIndicator(
                index: index,
                isActive: isActive,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                size: size,
              );
          }
        }),
      ),
    );
  }

  Widget _buildDotIndicator({
    required int index,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required double size,
  }) {
    return GestureDetector(
      onTap: () => onIndicatorTap?.call(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? activeColor : inactiveColor,
        ),
      ),
    );
  }

  Widget _buildNumberIndicator({
    required int index,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required double size,
  }) {
    return GestureDetector(
      onTap: () => onIndicatorTap?.call(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontSize: size * 0.8,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLineIndicator({
    required int index,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required double size,
  }) {
    return GestureDetector(
      onTap: () => onIndicatorTap?.call(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: size * 2,
        height: size / 2,
        decoration: BoxDecoration(
          color: isActive ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(size / 4),
        ),
      ),
    );
  }
} 