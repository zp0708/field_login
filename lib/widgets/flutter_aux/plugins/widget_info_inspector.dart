import 'package:field_login/widgets/flutter_aux/utils/hit_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/binding_ambiguate.dart';
import '../widgets/inspector_overlay.dart';

import 'pluggable.dart';
import '../utils/constants.dart';

class WidgetInfoInspector extends Pluggable {
  @override
  String get name => 'WidgetInfo';

  @override
  String get display => '组件信息';

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return _WidgetInfoInspectorPage();
  }

  @override
  bool get isOverlay => true;

  @override
  String get tips => '点击组件查看组件信息';
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

  final InspectorSelection selection;

  void _inspectAt(Offset? position) {
    final List<RenderObject> selected = HitTest.hitTest(position, edgeHitMargin: 2.0);
    setState(() {
      selection.candidates = selected;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handlePanDown(DragDownDetails event) {
    _lastPointerLocation = event.globalPosition;
    _inspectAt(event.globalPosition);
  }

  void _handlePanEnd(DragEndDetails details) {
    final Rect bounds = (Offset.zero & (window.physicalSize / window.devicePixelRatio)).deflate(1.0);
    if (!bounds.contains(_lastPointerLocation!)) {
      setState(() {
        selection.clear();
      });
    }
  }

  void _handleTap() {
    if (_lastPointerLocation != null) {
      _inspectAt(_lastPointerLocation);
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
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
    children.add(gesture);
    children.add(InspectorOverlay(selection: selection));
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        textDirection: TextDirection.ltr,
        children: children,
      ),
    );
  }
}

class _DebugPaintButton extends StatefulWidget {
  const _DebugPaintButton();

  @override
  State<StatefulWidget> createState() => _DebugPaintButtonState();
}

class _DebugPaintButtonState extends State<_DebugPaintButton> {
  double _dx = windowSize.width - dotSize.width - margin * 2;
  double _dy = windowSize.width - dotSize.width - bottomDistance;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _dx,
      top: _dy,
      child: SizedBox(
        width: dotSize.width,
        height: dotSize.width,
        child: GestureDetector(
          onPanUpdate: _buttonPanUpdate,
          child: FloatingActionButton(
            elevation: 10,
            onPressed: _showAllSize,
            child: Icon(Icons.all_out_sharp),
          ),
        ),
      ),
    );
  }

  void _buttonPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dx = details.globalPosition.dx - dotSize.width / 2;
      _dy = details.globalPosition.dy - dotSize.width / 2;
    });
  }

  void _showAllSize() async {
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

  @override
  void dispose() {
    super.dispose();
    debugPaintSizeEnabled = false;
    bindingAmbiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) {
      late RenderObjectVisitor visitor;
      visitor = (RenderObject child) {
        child.markNeedsPaint();
        child.visitChildren(visitor);
      };
      bindingAmbiguate(RendererBinding.instance)?.renderView.visitChildren(visitor);
    });
  }
}
