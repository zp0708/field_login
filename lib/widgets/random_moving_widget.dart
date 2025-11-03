import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RandomMovingChildren extends StatefulWidget {
  final List<Widget> children;
  final double speed;
  final Size? estimatedChildSize;
  final int collisionCheckIntervalMs;
  final Curve? curve;

  const RandomMovingChildren({
    super.key,
    required this.children,
    this.speed = 50,
    this.estimatedChildSize,
    this.collisionCheckIntervalMs = 200,
    this.curve,
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
  final Set<String> _cooldowns = {}; // 碰撞冷却表

  Size? _containerSize;
  Timer? _collisionTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializePositions());
    _collisionTimer = Timer.periodic(
      Duration(milliseconds: widget.collisionCheckIntervalMs),
      (_) => _checkCollisions(),
    );
  }

  void _initializePositions() {
    if (_containerSize == null) return;

    for (int i = 0; i < widget.children.length; i++) {
      _startPositions[i] = _randomPosition(i);
      _endPositions[i] = _randomPosition(i);
      _createController(i);
      _startChildAnimation(i);
    }
    setState(() {});
  }

  void _createController(int index) {
    _controllers[index]?.dispose();
    final controller = AnimationController(vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startPositions[index] = _endPositions[index]!;
        _endPositions[index] = _randomPosition(index);
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
    );

    final controller = _controllers[index]!;
    controller.duration = duration;
    _animations[index] = Tween(begin: start, end: end).animate(CurvedAnimation(
      parent: controller,
      curve: widget.curve ?? Curves.linear,
    ));
    controller.forward(from: 0);
  }

  Offset _randomPosition(int index) {
    final container = _containerSize;
    if (container == null) return Offset.zero;
    final size = _childSizes[index] ?? widget.estimatedChildSize ?? const Size(40, 40);
    final dx = _rnd.nextDouble() * max(1, container.width - size.width);
    final dy = _rnd.nextDouble() * max(1, container.height - size.height);
    return Offset(dx, dy);
  }

  void _checkCollisions() {
    if (_containerSize == null) return;
    final entries = _animations.entries.toList();

    for (int i = 0; i < entries.length; i++) {
      for (int j = i + 1; j < entries.length; j++) {
        final iKey = entries[i].key;
        final jKey = entries[j].key;
        final pairKey = '$iKey-$jKey';
        if (_cooldowns.contains(pairKey)) continue;

        final iPos = entries[i].value.value;
        final jPos = entries[j].value.value;

        final iSize = _childSizes[iKey] ?? widget.estimatedChildSize ?? const Size(40, 40);
        final jSize = _childSizes[jKey] ?? widget.estimatedChildSize ?? const Size(40, 40);

        final iRect = Rect.fromLTWH(iPos.dx, iPos.dy, iSize.width, iSize.height);
        final jRect = Rect.fromLTWH(jPos.dx, jPos.dy, jSize.width, jSize.height);

        if (iRect.overlaps(jRect)) {
          _cooldowns.add(pairKey);
          _handleCollision(iKey, jKey);
          // 短暂冷却 800ms，避免反复触发
          Future.delayed(const Duration(milliseconds: 800), () {
            _cooldowns.remove(pairKey);
          });
        }
      }
    }
  }

  void _handleCollision(int i, int j) {
    final posA = _animations[i]?.value ?? Offset.zero;
    final posB = _animations[j]?.value ?? Offset.zero;

    final dir = (posA - posB);
    final dirNorm = dir.distance == 0 ? const Offset(1, 0) : Offset(dir.dx / dir.distance, dir.dy / dir.distance);

    final distance = 80 + _rnd.nextDouble() * 60; // 偏离距离
    final newA = _clampPosition(posA + dirNorm * distance, i);
    final newB = _clampPosition(posB - dirNorm * distance, j);

    // 重启动画
    _restartAnimation(i, newA);
    _restartAnimation(j, newB);
  }

  void _restartAnimation(int index, Offset newTarget) {
    final controller = _controllers[index];
    if (controller == null) return;
    controller.stop();

    _startPositions[index] = _animations[index]?.value ?? Offset.zero;
    _endPositions[index] = newTarget;
    _startChildAnimation(index);
  }

  Offset _clampPosition(Offset pos, int index) {
    final container = _containerSize;
    if (container == null) return pos;
    final size = _childSizes[index] ?? widget.estimatedChildSize ?? const Size(40, 40);
    final dx = pos.dx.clamp(0, container.width - size.width);
    final dy = pos.dy.clamp(0, container.height - size.height);
    return Offset(dx.toDouble(), dy.toDouble());
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _collisionTimer?.cancel();
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
                    onChange: (size) => _childSizes[i] = size,
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
