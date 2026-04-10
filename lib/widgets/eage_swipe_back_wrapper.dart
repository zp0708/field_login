import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manicure/component/navigator_shell/navigator_provider.dart';

class EdgeSwipeBackWrapper extends StatefulWidget {
  const EdgeSwipeBackWrapper({
    super.key,
    required this.child,
    this.edgeWidth = 40.0, // 触发边缘的宽度（离屏幕左侧多近才算边缘滑动）
    this.swipeThreshold = 0.4, // 滑动超过屏幕百分之多少自动关闭
    this.onPopped, // 侧滑完成后的自定义回调
    this.enableShadow = true, // 是否开启左侧的物理阴影
    this.notifier, // 控制显示隐藏的 notifier
    this.offset = const Offset(1.0, 0.0), // 隐藏时的偏移量
  });

  final Widget child;
  final double edgeWidth;
  final double swipeThreshold;
  final VoidCallback? onPopped;
  final bool enableShadow;
  final ValueNotifier<bool>? notifier;
  final Offset offset;

  @override
  State<EdgeSwipeBackWrapper> createState() => _EdgeSwipeBackWrapperState();
}

class _EdgeSwipeBackWrapperState extends State<EdgeSwipeBackWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isDraggingFromEdge = false;

  @override
  void initState() {
    super.initState();
    // 持续时间设为 300ms，匹配原生返回动画的时长
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (widget.notifier != null) {
      _controller.value = widget.notifier!.value ? 0.0 : 1.0;
      widget.notifier!.addListener(_onNotifierChanged);
    }

    _updateAnimation();
  }

  void _updateAnimation() {
    // 动画范围：从 0 (原位) 到 1.0 (完全移出屏幕)
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: widget.offset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void didUpdateWidget(EdgeSwipeBackWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != widget.notifier) {
      oldWidget.notifier?.removeListener(_onNotifierChanged);
      widget.notifier?.addListener(_onNotifierChanged);
      if (widget.notifier != null) {
        _controller.value = widget.notifier!.value ? 0.0 : 1.0;
      }
    }
    if (oldWidget.offset != widget.offset) {
      _updateAnimation();
    }
  }

  void _onNotifierChanged() {
    if (widget.notifier!.value) {
      _controller.animateTo(0.0, curve: Curves.easeOut);
    } else {
      _controller.animateTo(1.0, curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    widget.notifier?.removeListener(_onNotifierChanged);
    _controller.dispose();
    super.dispose();
  }

  // --- 1. 拦截手势：只认边缘 ---
  void _handleDragStart(DragStartDetails details) {
    // 只有当手指按下的 x 坐标小于设定的边缘宽度时，才允许拖拽
    if (details.localPosition.dx <= widget.edgeWidth) {
      _isDraggingFromEdge = true;
    }
  }

  // --- 2. 强行跟手：线性更新 ---
  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDraggingFromEdge) return;

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null || box.size.width == 0) return;

    // 动态计算滑动比例并直接赋给 controller
    _controller.value += details.delta.dx / box.size.width;
  }

  // --- 3. 物理决断：松手后的去留 ---
  void _handleDragEnd(DragEndDetails details) {
    if (!_isDraggingFromEdge) return;
    _isDraggingFromEdge = false;

    // 获取松手瞬间的水平初速度
    final velocity = details.velocity.pixelsPerSecond.dx;

    // 判定条件：速度够快(>300) 或 滑动距离过半
    if (velocity > 300 || _controller.value > widget.swipeThreshold) {
      // 决定离开：顺滑地把剩下的动画跑完
      _controller.animateTo(1.0, curve: Curves.easeOut).then((_) {
        if (widget.onPopped != null) {
          widget.onPopped!();
        }
      });
    } else {
      // 决定挽留：弹回原位
      _controller.animateBack(0.0, curve: Curves.fastOutSlowIn);
    }
  }

  // 处理手势被系统意外打断的情况
  void _handleDragCancel() {
    if (_isDraggingFromEdge) {
      _isDraggingFromEdge = false;
      _controller.animateBack(0.0, curve: Curves.fastOutSlowIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // HitTestBehavior.translucent 保证不管点击处有没有内容都能触发
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onHorizontalDragCancel: _handleDragCancel,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            // 模拟 Cupertino 的左侧渐变阴影，增加物理层级感
            boxShadow: widget.enableShadow
                ? [
                    const BoxShadow(
                      color: Color(0x1A000000), // 极淡的黑色
                      blurRadius: 15.0,
                      offset: Offset(-5, 0),
                    )
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
