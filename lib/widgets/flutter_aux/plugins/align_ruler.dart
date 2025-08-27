import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pluggable.dart';
import '../utils/constants.dart';
import '../utils/hit_test.dart';
import '../widgets/inspector_overlay.dart';

class AlignRulerPlugin extends Pluggable {
  @override
  String get name => 'AlignRuler';

  @override
  String get display => '对齐标尺';

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return _AlignRuler();
  }

  @override
  bool get isOverlay => true;
}

class _AlignRuler extends StatefulWidget {
  const _AlignRuler();

  @override
  _AlignRulerState createState() => _AlignRulerState();
}

class _AlignRulerState extends State<_AlignRuler> {
  Size _windowSize = windowSize;
  final Size _dotSize = Size(80, 80);
  Offset _dotPosition = Offset.zero;
  BorderRadius? _radius;
  late Offset _dotOffset;
  final TextStyle _fontStyle = TextStyle(color: Colors.red, fontSize: 15);
  Size _textSize = Size.zero;
  Offset _toolBarPosition = Offset(60, 60);
  Offset _dragStartPosition = Offset.zero;
  Offset _startPosition = Offset.zero;
  bool _switched = false;
  final InspectorSelection _selection = WidgetInspectorService.instance.selection;

  @override
  void initState() {
    _dotPosition = _windowSize.center(Offset.zero);
    _radius = BorderRadius.circular(_dotSize.longestSide);
    _dotOffset = _dotSize.center(Offset.zero);
    super.initState();
    _textSize = _getTextSize();
    _selection.clear();
  }

  void _onToolbarPanStart(DragStartDetails dragDetails) {
    _dragStartPosition = dragDetails.globalPosition;
    _startPosition = _toolBarPosition;
  }

  void _toolBarPanUpdate(DragUpdateDetails dragDetails) {
    setState(() {
      _toolBarPosition = _startPosition + (dragDetails.globalPosition - _dragStartPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails dragDetails) {
    setState(() {
      _dotPosition = dragDetails.globalPosition;
    });
  }

  void _onPanEnd(DragEndDetails dragDetails) {
    if (!_switched) return;
    final List<RenderObject> objects = HitTest.hitTest(_dotPosition);
    _selection.candidates = objects;
    Offset offset = Offset.zero;
    for (var obj in objects) {
      var translation = obj.getTransformTo(null).getTranslation();
      Rect rect = obj.paintBounds.shift(Offset(translation.x, translation.y));
      if (rect.contains(_dotPosition)) {
        double dx, dy = 0.0;
        double perW = rect.width / 2;
        double perH = rect.height / 2;
        if (_dotPosition.dx <= perW + translation.x) {
          dx = translation.x;
        } else {
          dx = translation.x + rect.width;
        }
        if (_dotPosition.dy <= translation.y + perH) {
          dy = translation.y;
        } else {
          dy = translation.y + rect.height;
        }
        offset = Offset(dx, dy);
        break;
      }
    }
    setState(() {
      _dotPosition = offset == Offset.zero ? _dotPosition : offset;
      HapticFeedback.mediumImpact();
    });
  }

  Size _getTextSize() {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: 'for caculate size',
        style: _fontStyle,
      ),
    );
    textPainter.layout();
    return Size(textPainter.width, textPainter.height);
  }

  void _switchChanged(bool swi) {
    setState(() {
      _switched = swi;
      if (!_switched) {
        _selection.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_windowSize.isEmpty) {
      _windowSize = MediaQuery.of(context).size;
      _dotPosition = _windowSize.center(Offset.zero);
    }
    const TextStyle style = TextStyle(fontSize: 17, color: Colors.black);
    Widget toolBar = Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 16, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 26, right: 26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Left: ${_dotPosition.dx.toStringAsFixed(1)}',
                        style: style,
                      ),
                      Padding(padding: const EdgeInsets.only(top: 8)),
                      Text(
                        'Right: ${(_windowSize.width - _dotPosition.dx).toStringAsFixed(1)}',
                        style: style,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Top: ${_dotPosition.dy.toStringAsFixed(1)}', style: style),
                      Padding(padding: const EdgeInsets.only(top: 8)),
                      Text(
                        'Bottom: ${(_windowSize.height - _dotPosition.dy).toStringAsFixed(1)}',
                        style: style,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  height: 30,
                  child: Switch(
                    value: _switched,
                    onChanged: _switchChanged,
                    activeColor: Colors.red,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      '开启后松手将会自动吸附至最近widget',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );

    double verticalLeft = _dotPosition.dx + 10;
    double horizontalTop = _dotPosition.dy - _textSize.height;

    return Container(
      color: Colors.transparent,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: horizontalTop,
            left: _dotPosition.dx / 2 - _textSize.width / 2,
            child: Text(_dotPosition.dx.toStringAsFixed(1), style: _fontStyle),
          ),
          Positioned(
            left: verticalLeft,
            top: _dotPosition.dy / 2 - _textSize.height / 2,
            child: Text(_dotPosition.dy.toStringAsFixed(1), style: _fontStyle),
          ),
          Positioned(
            left: _dotPosition.dx + (_windowSize.width - _dotPosition.dx) / 2 - _textSize.width / 2,
            top: horizontalTop,
            child: Text(
              (_windowSize.width - _dotPosition.dx).toStringAsFixed(1),
              style: _fontStyle,
            ),
          ),
          Positioned(
            top: _dotPosition.dy + (_windowSize.height - _dotPosition.dy) / 2 - _textSize.height / 2,
            left: verticalLeft,
            child: Text(
              (_windowSize.height - _dotPosition.dy).toStringAsFixed(1),
              style: _fontStyle,
            ),
          ),
          Positioned(
            left: _dotPosition.dx,
            top: 0,
            child: Container(
              width: 1,
              height: _windowSize.height,
              color: const Color(0xffff0000),
            ),
          ),
          Positioned(
            left: 0,
            top: _dotPosition.dy,
            child: Container(
              width: _windowSize.width,
              height: 1,
              color: const Color(0xffff0000),
            ),
          ),
          Positioned(
            left: _dotPosition.dx - _dotOffset.dx,
            top: _dotPosition.dy - _dotOffset.dy,
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Container(
                height: _dotSize.height,
                width: _dotSize.width,
                decoration: BoxDecoration(
                  borderRadius: _radius,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    height: _dotSize.width / 2.5,
                    width: _dotSize.height / 2.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withAlpha(150),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: _toolBarPosition.dx,
            top: _toolBarPosition.dy,
            child: GestureDetector(
              onPanStart: _onToolbarPanStart,
              onPanUpdate: _toolBarPanUpdate,
              child: toolBar,
            ),
          ),
          InspectorOverlay(selection: _selection, needDescription: false, needEdges: false),
        ],
      ),
    );
  }
}
