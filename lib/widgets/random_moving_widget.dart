import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RandomMovingChildren extends StatefulWidget {
  final List<Widget> children;
  final Duration moveDuration;

  /// 子组件的大致尺寸，用于初始化时估算位置，避免超出容器
  final Size? estimatedChildSize;

  const RandomMovingChildren({
    super.key,
    required this.children,
    this.moveDuration = const Duration(seconds: 4),
    this.estimatedChildSize,
  });

  @override
  State<RandomMovingChildren> createState() => _RandomMovingChildrenState();
}

class _RandomMovingChildrenState extends State<RandomMovingChildren> with SingleTickerProviderStateMixin {
  final Random _rnd = Random();

  final Map<int, Offset> _startPositions = {};
  final Map<int, Offset> _endPositions = {};
  final Map<int, Size> _childSizes = {};

  Size? _containerSize;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.moveDuration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startNextMove();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePositions();
    });
  }

  void _initializePositions() {
    if (_containerSize == null) return;
    for (int i = 0; i < widget.children.length; i++) {
      final pos = _randomPositionForChild(i);
      _startPositions[i] = pos;
      _endPositions[i] = _randomPositionForChild(i);
    }
    _controller.forward(from: 0);
  }

  void _startNextMove() {
    for (int i = 0; i < widget.children.length; i++) {
      _startPositions[i] = _endPositions[i]!;
      _endPositions[i] = _randomPositionForChild(i);
    }
    _controller.forward(from: 0);
  }

  Offset _randomPositionForChild(int index) {
    final container = _containerSize;
    if (container == null) return Offset.zero;

    // 使用测量尺寸，否则使用估计尺寸
    final childSize = _childSizes[index] ?? widget.estimatedChildSize ?? const Size(40, 40);

    final double w = childSize.width;
    final double h = childSize.height;

    final dx = _rnd.nextDouble() * max(1, container.width - w);
    final dy = _rnd.nextDouble() * max(1, container.height - h);
    return Offset(dx, dy);
  }

  @override
  void dispose() {
    _controller.dispose();
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
              animation: _controller,
              builder: (context, child) {
                final start = _startPositions[i] ?? Offset.zero;
                final end = _endPositions[i] ?? start;
                final offset = Offset.lerp(start, end, _controller.value)!;
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

/// 🔹 尺寸测量组件
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
