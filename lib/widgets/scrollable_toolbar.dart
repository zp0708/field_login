import 'dart:math';
import 'package:flutter/material.dart';

class ScrollableToolbar extends StatefulWidget {
  final Widget child;
  final double height;
  final double maxScrollDistance;
  final ScrollController scrollController;

  const ScrollableToolbar({
    super.key,
    required this.child,
    this.height = 88.0,
    this.maxScrollDistance = 44.0,
    required this.scrollController,
  });

  @override
  State<ScrollableToolbar> createState() => _ScrollableToolbarState();
}

class _ScrollableToolbarState extends State<ScrollableToolbar> {
  late ScrollController _scrollController;
  double _toolbarOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset - 10;
    if (scrollOffset <= 0) {
      // 在顶部，工具条完全显示
      _toolbarOffset = 0;
    } else {
      // 工具条平滑跟随滚动
      _toolbarOffset = min(scrollOffset, widget.maxScrollDistance);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -_toolbarOffset,
      left: 0,
      right: 0,
      height: widget.height,
      child: widget.child,
    );
  }
}
