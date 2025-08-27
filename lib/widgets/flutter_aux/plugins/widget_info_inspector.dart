import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/binding_ambiguate.dart';
import '../widgets/inspector_overlay.dart';

import 'pluggable.dart';
import '../utils/constants.dart';
import '../utils/hit_test.dart';

class WidgetInfoInspector extends Pluggable {
  @override
  String get name => 'WidgetInfo';

  @override
  String get display => '组件检查器';

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return _WidgetInfoInspectorPage();
  }

  @override
  bool get isOverlay => true;

  @override
  String get tips => '点击任意组件查看详细信息，长按开启尺寸调试';
}

class _WidgetInfoInspectorPage extends StatefulWidget {
  const _WidgetInfoInspectorPage();

  @override
  _WidgetInfoInspectorState createState() => _WidgetInfoInspectorState();
}

class _WidgetInfoInspectorState extends State<_WidgetInfoInspectorPage> with WidgetsBindingObserver {
  _WidgetInfoInspectorState() : selection = WidgetInspectorService.instance.selection;

  final window = bindingAmbiguate(WidgetsBinding.instance)!.window;

  Offset? _lastPointerLocation;
  bool _isInspecting = false;

  final InspectorSelection selection;

  void _inspectAt(Offset? position) {
    final List<RenderObject> selected = HitTest.hitTest(position, edgeHitMargin: 2.0);
    setState(() {
      selection.candidates = selected;
    });
  }

  void _handlePanDown(DragDownDetails event) {
    _lastPointerLocation = event.globalPosition;
    _inspectAt(event.globalPosition);
    setState(() {
      _isInspecting = true;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    final Rect bounds = (Offset.zero & (window.physicalSize / window.devicePixelRatio)).deflate(1.0);
    if (!bounds.contains(_lastPointerLocation!)) {
      setState(() {
        selection.clear();
        _isInspecting = false;
      });
    }
  }

  void _handleTap() {
    if (_lastPointerLocation != null) {
      _inspectAt(_lastPointerLocation);
      setState(() {
        _isInspecting = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selection.clear();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];

    GestureDetector gesture = GestureDetector(
      onTap: _handleTap,
      onPanDown: _handlePanDown,
      onPanEnd: _handlePanEnd,
      behavior: HitTestBehavior.opaque,
      child: IgnorePointer(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: _isInspecting ? Colors.black.withOpacity(0.2) : Colors.transparent,
        ),
      ),
    );

    children.add(gesture);
    children.add(InspectorOverlay(selection: selection));

    // Add close button as a separate floating element when inspecting
    if (_isInspecting) {
      children.add(_buildCloseButton());
    }

    children.add(_EnhancedDebugPaintButton(
      onLongPress: _toggleDebugPaint,
    ));

    return Stack(
      textDirection: TextDirection.ltr,
      children: children,
    );
  }

  void _closeInspection() {
    setState(() {
      _isInspecting = false;
      selection.clear();
    });
  }

  Widget _buildCloseButton() {
    return Positioned(
      left: 40,
      bottom: 40,
      child: GestureDetector(
        onTap: _closeInspection,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2C3E50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _toggleDebugPaint() {
    debugPaintSizeEnabled = !debugPaintSizeEnabled;
    setState(() {
      late RenderObjectVisitor visitor;
      visitor = (RenderObject child) {
        child.markNeedsPaint();
        child.visitChildren(visitor);
      };
      bindingAmbiguate(RendererBinding.instance)?.renderView.visitChildren(visitor);
    });
  }
}

class _EnhancedDebugPaintButton extends StatefulWidget {
  const _EnhancedDebugPaintButton({
    required this.onLongPress,
  });

  final VoidCallback onLongPress;

  @override
  State<StatefulWidget> createState() => _EnhancedDebugPaintButtonState();
}

class _EnhancedDebugPaintButtonState extends State<_EnhancedDebugPaintButton> {
  double _dx = windowSize.width - 80 - 20;
  double _dy = windowSize.height - 80 - 100;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _dx,
      top: _dy,
      child: GestureDetector(
        onPanStart: _buttonPanStart,
        onPanUpdate: _buttonPanUpdate,
        onPanEnd: _buttonPanEnd,
        onTap: widget.onLongPress,
        child: Transform.scale(
          scale: _isDragging ? 1.1 : 1.0,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF667EEA),
                  const Color(0xFF764BA2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withAlpha(102),
                  blurRadius: _isDragging ? 20 : 15,
                  offset: const Offset(0, 8),
                  spreadRadius: _isDragging ? 2 : 0,
                ),
              ],
            ),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                debugPaintSizeEnabled ? Icons.visibility_off : Icons.search,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _buttonPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _buttonPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dx = (details.globalPosition.dx - 35).clamp(0, windowSize.width - 70);
      _dy = (details.globalPosition.dy - 35).clamp(0, windowSize.height - 70);
    });
  }

  void _buttonPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
  }
}
