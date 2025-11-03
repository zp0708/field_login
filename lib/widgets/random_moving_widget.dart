import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RandomMovingChildren extends StatefulWidget {
  final List<Widget> children;

  /// 每秒移动的像素速度（默认 50px/s）
  final double speed;

  /// 子组件的估计尺寸，用于初始随机布局
  final Size? estimatedChildSize;

  const RandomMovingChildren({
    super.key,
    required this.children,
    this.speed = 50,
    this.estimatedChildSize,
  });

  @override
  State<RandomMovingChildren> createState() => _RandomMovingChildrenState();
}

class _RandomMovingChildrenState extends State<RandomMovingChildren> with TickerProviderStateMixin {
  final Random _rnd = Random();

  final Map<int, AnimationController> _controllers = {};
  final Map<int, Animation<Offset>> _animations = {};
  final Map<int, Offset> _startPositions = {};
  final Map<int, Offset> _endPositions = {};
  final Map<int, Size> _childSizes = {};

  Size? _containerSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializePositions());
  }

  void _initializePositions() {
    if (_containerSize == null) return;
    for (int i = 0; i < widget.children.length; i++) {
      _startPositions[i] = _randomPositionForChild(i);
      _endPositions[i] = _randomPositionForChild(i);
      _createControllerForChild(i);
      _startChildAnimation(i);
    }
    setState(() {});
  }

  void _createControllerForChild(int index) {
    _controllers[index]?.dispose();

    final controller = AnimationController(vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startPositions[index] = _endPositions[index]!;
        _endPositions[index] = _randomPositionForChild(index);
        _startChildAnimation(index);
      }
    });
    _controllers[index] = controller;
  }

  void _startChildAnimation(int index) {
    final start = _startPositions[index]!;
    final end = _endPositions[index]!;

    final distance = (end - start).distance;
    final duration = Duration(
      milliseconds: (distance / widget.speed * 1000).round().clamp(300, 8000),
    ); // 限制最短/最长动画时间

    final controller = _controllers[index]!;
    controller.duration = duration;

    _animations[index] = Tween<Offset>(begin: start, end: end).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    ));

    controller.forward(from: 0);
  }

  Offset _randomPositionForChild(int index) {
    final container = _containerSize;
    if (container == null) return Offset.zero;

    final childSize = _childSizes[index] ?? widget.estimatedChildSize ?? const Size(40, 40);

    final double w = childSize.width;
    final double h = childSize.height;

    final dx = _rnd.nextDouble() * max(1, container.width - w);
    final dy = _rnd.nextDouble() * max(1, container.height - h);
    return Offset(dx, dy);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _containerSize = Size(constraints.maxWidth, constraints.maxHeight);
      return Stack(
        children: [
          for (int i = 0; i < widget.children.length; i++)
            AnimatedBuilder(
              animation: _animations[i] ?? AlwaysStoppedAnimation(Offset.zero),
              builder: (context, child) {
                final offset = _animations[i]?.value ?? Offset.zero;
                return Positioned(
                  left: offset.dx,
                  top: offset.dy,
                  child: MeasureSize(
                    onChange: (size) {
                      _childSizes[i] = size;
                    },
                    child: child!,
                  ),
                );
              },
              child: widget.children[i],
            ),
        ],
      );
    });
  }
}

/// 🔹 尺寸测量组件（不依赖 GlobalKey）
class MeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChange;

  const MeasureSize({
    super.key,
    required this.onChange,
    required Widget child,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(onChange);
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  final ValueChanged<Size> onChange;
  Size? _oldSize;

  _MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size;
    if (newSize != _oldSize && newSize != null) {
      _oldSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChange(newSize);
      });
    }
  }
}
