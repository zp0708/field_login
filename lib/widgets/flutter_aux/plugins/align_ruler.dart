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
  final Size _dotSize = Size(60, 60);
  Offset _dotPosition = Offset.zero;
  late Offset _dotOffset;
  final TextStyle _fontStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    shadows: [
      Shadow(
        offset: Offset(1, 1),
        blurRadius: 2,
        color: Colors.black54,
      ),
    ],
  );
  Size _textSize = Size.zero;
  Offset _toolBarPosition = Offset(20, 60);
  Offset _dragStartPosition = Offset.zero;
  Offset _startPosition = Offset.zero;
  bool _switched = false;
  final InspectorSelection _selection = WidgetInspectorService.instance.selection;

  @override
  void initState() {
    _dotPosition = _windowSize.center(Offset.zero);
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
        text: '999.9',
        style: _fontStyle,
      ),
    );
    textPainter.layout();
    return Size(textPainter.width + 8, textPainter.height + 4);
  }

  void _switchChanged(bool swi) {
    setState(() {
      _switched = swi;
      if (!_switched) {
        _selection.clear();
      }
    });
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withAlpha(50),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: color,
              ),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementLabel(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Color(0xFF4A90E2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: _fontStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_windowSize.isEmpty) {
      _windowSize = MediaQuery.of(context).size;
      _dotPosition = _windowSize.center(Offset.zero);
    }

    Widget toolBar = Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .15),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.straighten,
                  size: 18,
                  color: Color(0xFF4A90E2),
                ),
                SizedBox(width: 8),
                Text(
                  '对齐标尺',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _switched ? Color(0xFF4A90E2) : Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _switched ? 'ON' : 'OFF',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _switched ? Colors.white : Color(0xFF999999),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Position Data
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildMetricCard(
                        '左边距',
                        _dotPosition.dx.toStringAsFixed(1),
                        Icons.keyboard_arrow_left,
                        Color(0xFF4A90E2),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        '上边距',
                        _dotPosition.dy.toStringAsFixed(1),
                        Icons.keyboard_arrow_up,
                        Color(0xFF50C878),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildMetricCard(
                        '右边距',
                        (_windowSize.width - _dotPosition.dx).toStringAsFixed(1),
                        Icons.keyboard_arrow_right,
                        Color(0xFFFF6B6B),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        '下边距',
                        (_windowSize.height - _dotPosition.dy).toStringAsFixed(1),
                        Icons.keyboard_arrow_down,
                        Color(0xFFFFB347),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Switch section
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _switched ? Color(0xFF4A90E2) : Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Switch(
                        value: _switched,
                        onChanged: _switchChanged,
                        activeColor: Color(0xFF4A90E2),
                        activeTrackColor: Color(0xFF4A90E2).withAlpha(75),
                        inactiveThumbColor: Colors.grey[400],
                        inactiveTrackColor: Colors.grey[300],
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '智能吸附',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '松手后自动吸附至最近组件',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    double verticalLeft = _dotPosition.dx + 8;
    double horizontalTop = _dotPosition.dy - _textSize.height - 4;

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
            child: _buildMeasurementLabel(_dotPosition.dx.toStringAsFixed(1)),
          ),
          Positioned(
            left: verticalLeft,
            top: _dotPosition.dy / 2 - _textSize.height / 2,
            child: _buildMeasurementLabel(_dotPosition.dy.toStringAsFixed(1)),
          ),
          Positioned(
            left: _dotPosition.dx + (_windowSize.width - _dotPosition.dx) / 2 - _textSize.width / 2,
            top: horizontalTop,
            child: _buildMeasurementLabel((_windowSize.width - _dotPosition.dx).toStringAsFixed(1)),
          ),
          Positioned(
            top: _dotPosition.dy + (_windowSize.height - _dotPosition.dy) / 2 - _textSize.height / 2,
            left: verticalLeft,
            child: _buildMeasurementLabel((_windowSize.height - _dotPosition.dy).toStringAsFixed(1)),
          ),
          Positioned(
            left: _dotPosition.dx - 0.5,
            top: 0,
            child: Container(
              width: 1,
              height: _windowSize.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4A90E2).withAlpha(75),
                    Color(0xFF4A90E2),
                    Color(0xFF4A90E2),
                    Color(0xFF4A90E2).withAlpha(75),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF4A90E2).withAlpha(75),
                    blurRadius: 2,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: _dotPosition.dy - 0.5,
            child: Container(
              width: _windowSize.width,
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF4A90E2).withAlpha(75),
                    Color(0xFF4A90E2),
                    Color(0xFF4A90E2),
                    Color(0xFF4A90E2).withAlpha(75),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF4A90E2).withAlpha(75),
                    blurRadius: 2,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
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
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Color(0xFF4A90E2),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4A90E2).withAlpha(75),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha(75),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    height: 16,
                    width: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4A90E2),
                    ),
                    child: Icon(
                      Icons.my_location,
                      size: 10,
                      color: Colors.white,
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
