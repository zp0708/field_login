import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import '../utils/binding_ambiguate.dart';
import '../widgets/inspector_overlay.dart';

import 'pluggable.dart';
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
    final ui.FlutterView view = ui.PlatformDispatcher.instance.views.first;
    final Rect bounds = (Offset.zero & (view.physicalSize / view.devicePixelRatio)).deflate(1.0);
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
          color: _isInspecting ? Colors.black.withAlpha(50) : Colors.transparent,
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
                color: Colors.black.withAlpha(75),
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
      bindingAmbiguate(RendererBinding.instance)?.renderViews.first.visitChildren(visitor);
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
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 90,
      bottom: 40,
      child: GestureDetector(
        onTap: widget.onLongPress,
        child: Container(
          width: 40,
          height: 40,
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
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              debugPaintSizeEnabled ? Icons.visibility_off : Icons.line_style_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
