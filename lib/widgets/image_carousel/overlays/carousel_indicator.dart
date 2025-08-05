import 'package:flutter/material.dart';

/// 轮播指示器类型
enum CarouselIndicatorType {
  dots,      // 圆点
  numbers,   // 数字
  lines,     // 线条
  progress,  // 进度条
}

/// 轮播指示器组件
class CarouselIndicator extends StatefulWidget {
  final int currentIndex;
  final int totalCount;
  final CarouselIndicatorType type;
  final Color? activeColor;
  final Color? inactiveColor;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onIndicatorTap;
  // 新增功能
  final bool enableAnimation; // 启用动画
  final Duration animationDuration; // 动画持续时间
  final Curve animationCurve; // 动画曲线
  final bool enableTapToJump; // 启用点击跳转
  final Function(int index)? onIndicatorTapWithIndex; // 带索引的点击回调
  final double? activeSize; // 激活状态的大小
  final double? inactiveSize; // 非激活状态的大小
  final BorderRadius? borderRadius; // 圆角
  final BoxShadow? shadow; // 阴影

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
    // 新增参数
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.enableTapToJump = false,
    this.onIndicatorTapWithIndex,
    this.activeSize,
    this.inactiveSize,
    this.borderRadius,
    this.shadow,
  });

  @override
  State<CarouselIndicator> createState() => _CarouselIndicatorState();
}

class _CarouselIndicatorState extends State<CarouselIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.enableAnimation) {
      _animationController = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ));
    }
  }

  @override
  void didUpdateWidget(CarouselIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableAnimation && widget.currentIndex != oldWidget.currentIndex) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalCount <= 1) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.primaryColor;
    final inactiveColor = widget.inactiveColor ?? theme.disabledColor;
    final size = widget.size ?? 8.0;
    final activeSize = widget.activeSize ?? size * 1.2;
    final inactiveSize = widget.inactiveSize ?? size;

    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.totalCount, (index) {
          final isActive = index == widget.currentIndex;
          
          Widget indicator;
          switch (widget.type) {
            case CarouselIndicatorType.dots:
              indicator = _buildDotIndicator(
                index: index,
                isActive: isActive,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                activeSize: activeSize,
                inactiveSize: inactiveSize,
              );
              break;
            case CarouselIndicatorType.numbers:
              indicator = _buildNumberIndicator(
                index: index,
                isActive: isActive,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                activeSize: activeSize,
                inactiveSize: inactiveSize,
              );
              break;
            case CarouselIndicatorType.lines:
              indicator = _buildLineIndicator(
                index: index,
                isActive: isActive,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                activeSize: activeSize,
                inactiveSize: inactiveSize,
              );
              break;
            case CarouselIndicatorType.progress:
              indicator = _buildProgressIndicator(
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                size: size,
              );
              break;
          }

          // 添加动画效果
          if (widget.enableAnimation && isActive) {
            indicator = AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: indicator,
            );
          }

          return indicator;
        }),
      ),
    );
  }

  Widget _buildDotIndicator({
    required int index,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required double activeSize,
    required double inactiveSize,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onIndicatorTap?.call();
        if (widget.enableTapToJump && widget.onIndicatorTapWithIndex != null) {
          widget.onIndicatorTapWithIndex!(index);
        }
      },
      child: AnimatedContainer(
        duration: widget.animationDuration,
        curve: widget.animationCurve,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isActive ? activeSize : inactiveSize,
        height: isActive ? activeSize : inactiveSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? activeColor : inactiveColor,
          borderRadius: widget.borderRadius,
          boxShadow: widget.shadow != null ? [widget.shadow!] : null,
        ),
      ),
    );
  }

  Widget _buildNumberIndicator({
    required int index,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required double activeSize,
    required double inactiveSize,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onIndicatorTap?.call();
        if (widget.enableTapToJump && widget.onIndicatorTapWithIndex != null) {
          widget.onIndicatorTapWithIndex!(index);
        }
      },
      child: AnimatedContainer(
        duration: widget.animationDuration,
        curve: widget.animationCurve,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? activeColor : inactiveColor,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          boxShadow: widget.shadow != null ? [widget.shadow!] : null,
        ),
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontSize: isActive ? activeSize * 0.8 : inactiveSize * 0.8,
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
    required double activeSize,
    required double inactiveSize,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onIndicatorTap?.call();
        if (widget.enableTapToJump && widget.onIndicatorTapWithIndex != null) {
          widget.onIndicatorTapWithIndex!(index);
        }
      },
      child: AnimatedContainer(
        duration: widget.animationDuration,
        curve: widget.animationCurve,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: isActive ? activeSize * 2 : inactiveSize * 2,
        height: isActive ? activeSize / 2 : inactiveSize / 2,
        decoration: BoxDecoration(
          color: isActive ? activeColor : inactiveColor,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(activeSize / 4),
          boxShadow: widget.shadow != null ? [widget.shadow!] : null,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({
    required Color activeColor,
    required Color inactiveColor,
    required double size,
  }) {
    return Container(
      height: size / 2,
      decoration: BoxDecoration(
        color: inactiveColor,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(size / 4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 确保约束有效
          if (constraints.maxWidth.isInfinite || constraints.maxWidth <= 0) {
            return Container(
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(size / 4),
                boxShadow: widget.shadow != null ? [widget.shadow!] : null,
              ),
            );
          }
          
          final progressWidth = constraints.maxWidth * (widget.currentIndex + 1) / widget.totalCount;
          return Stack(
            children: [
              Container(
                width: progressWidth,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(size / 4),
                  boxShadow: widget.shadow != null ? [widget.shadow!] : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 