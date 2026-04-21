import 'package:flutter/material.dart';
import './draggable_widget.dart';

class DragPosition extends StatelessWidget {
  final Widget child;

  const DragPosition({super.key, required this.child, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onPanStart: (details) => DraggableScope.of(context).start(details.globalPosition),
      onPanUpdate: (details) => DraggableScope.of(context).move(details.delta),
      onPanEnd: (details) => DraggableScope.of(context).end(details.globalPosition),
      child: child,
    );
  }
}

class DragResize extends StatelessWidget {
  final Widget child;

  const DragResize({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => DraggableScope.of(context).start(details.globalPosition),
      onPanUpdate: (details) => DraggableScope.of(context).resize(details.delta),
      onPanEnd: (details) => DraggableScope.of(context).end(details.globalPosition),
      child: child,
    );
  }
}

class DragReset extends StatelessWidget {
  final Widget child;

  const DragReset({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => DraggableScope.of(context).reset(),
      child: child,
    );
  }
}
