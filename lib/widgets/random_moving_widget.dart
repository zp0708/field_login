import 'dart:math';
import 'package:flutter/material.dart';

class RandomMovingChildren extends StatefulWidget {
  final List<Widget> childrenBuilders;
  final Duration minMoveDuration;
  final Duration maxMoveDuration;

  const RandomMovingChildren({
    super.key,
    required this.childrenBuilders,
    this.minMoveDuration = const Duration(seconds: 4),
    this.maxMoveDuration = const Duration(seconds: 5),
  });

  @override
  State<RandomMovingChildren> createState() => _RandomMovingChildrenState();
}

class _RandomMovingChildrenState extends State<RandomMovingChildren> {
  final Random _rnd = Random();
  final List<GlobalKey> _childKeys = [];
  late List<Offset> _positions;
  late List<Duration> _durations;
  Size _containerSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _positions = List.filled(widget.childrenBuilders.length, Offset.zero);
    _durations = List.filled(widget.childrenBuilders.length, widget.minMoveDuration);
    _childKeys.addAll(List.generate(widget.childrenBuilders.length, (_) => GlobalKey()));
  }

  @override
  void didUpdateWidget(covariant RandomMovingChildren oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childrenBuilders.length != widget.childrenBuilders.length) {
      _positions = List.generate(
        widget.childrenBuilders.length,
        (i) => i < _positions.length ? _positions[i] : Offset.zero,
      );
      _durations = List.generate(
        widget.childrenBuilders.length,
        (i) => i < _durations.length ? _durations[i] : widget.minMoveDuration,
      );
      _childKeys.clear();
      _childKeys.addAll(List.generate(widget.childrenBuilders.length, (_) => GlobalKey()));
    }
  }

  Duration _randomDuration() {
    final minMs = widget.minMoveDuration.inMilliseconds;
    final maxMs = widget.maxMoveDuration.inMilliseconds;
    return Duration(milliseconds: minMs + _rnd.nextInt(maxMs - minMs + 1));
  }

  /// 随机生成合法位置（保证子组件不超出容器边界）
  Offset _randomPositionForChild(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    final childSize = renderBox?.size ?? const Size(50, 50);
    final maxX = max(0.0, _containerSize.width - childSize.width);
    final maxY = max(0.0, _containerSize.height - childSize.height);
    return Offset(_rnd.nextDouble() * maxX, _rnd.nextDouble() * maxY);
  }

  void _moveNext(int index) async {
    if (!mounted) return;

    setState(() {
      _positions[index] = _randomPositionForChild(_childKeys[index]);
      _durations[index] = _randomDuration();
    });

    await Future.delayed(_durations[index]);
    _moveNext(index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final newSize = Size(constraints.maxWidth, constraints.maxHeight);
      if (_containerSize != newSize) {
        _containerSize = newSize;
        // 初始化随机位置
        for (int i = 0; i < _positions.length; i++) {
          _positions[i] = Offset(
            _rnd.nextDouble() * _containerSize.width * 0.8,
            _rnd.nextDouble() * _containerSize.height * 0.8,
          );
          _durations[i] = _randomDuration();
        }

        // 启动连续动画
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (int i = 0; i < _positions.length; i++) {
            _moveNext(i);
          }
        });
      }

      return Stack(
        clipBehavior: Clip.none,
        children: List.generate(widget.childrenBuilders.length, (i) {
          final pos = _positions[i];
          return AnimatedPositioned(
            key: ValueKey('child_$i'),
            duration: _durations[i],
            curve: Curves.linear, // 匀速线性动画
            left: pos.dx,
            top: pos.dy,
            child: Container(
              key: _childKeys[i],
              child: widget.childrenBuilders[i],
            ),
          );
        }),
      );
    });
  }
}
