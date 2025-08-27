import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../flutter_aux.dart';

import 'pluggable.dart';

class ColorSucker extends Pluggable {
  @override
  String get name => 'ColorSucker';

  @override
  String get display => '颜色取色器';

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return _ColorSucker();
  }

  @override
  bool get isOverlay => true;

  @override
  String get tips => '拖拽放大镜查看屏幕上任意位置的颜色值';
}

class _ColorSucker extends StatefulWidget {
  const _ColorSucker();

  @override
  _ColorSuckerState createState() => _ColorSuckerState();
}

class _ColorSuckerState extends State<_ColorSucker> {
  late Size _magnifierSize;
  double? _scale;
  BorderRadius? _radius;
  Color _currentColor = Colors.white;
  Offset _magnifierPosition = Offset.zero;
  double _toolBarY = 80.0;
  double _toolBarX = 16.0;
  Offset _toolBarDragStart = Offset.zero;
  Offset _toolBarStartPosition = Offset.zero;
  Matrix4 _matrix = Matrix4.identity();
  late Size _windowSize;
  bool _excuting = false;
  Uint8List? _imageData;
  bool _isActive = false;

  @override
  void initState() {
    _windowSize = ui.window.physicalSize / ui.window.devicePixelRatio;
    _magnifierSize = Size(120, 120);
    _scale = 8;
    _radius = BorderRadius.circular(_magnifierSize.longestSide);
    _matrix = Matrix4.identity()..scale(_scale);
    _magnifierPosition = _windowSize.center(Offset.zero) - _magnifierSize.center(Offset.zero);
    super.initState();
  }

  void _onPanUpdate(DragUpdateDetails dragDetails) {
    _magnifierPosition = dragDetails.globalPosition - _magnifierSize.center(Offset.zero);
    double newX = dragDetails.globalPosition.dx;
    double newY = dragDetails.globalPosition.dy;
    final Matrix4 newMatrix = Matrix4.identity()
      ..translate(newX, newY)
      ..scale(_scale, _scale)
      ..translate(-newX, -newY);
    _matrix = newMatrix;
    _searchPixel(dragDetails.globalPosition);
    setState(() {
      _isActive = true;
    });
  }

  void _toolBarPanStart(DragStartDetails details) {
    _toolBarDragStart = details.globalPosition;
    _toolBarStartPosition = Offset(_toolBarX, _toolBarY);
  }

  void _toolBarPanUpdate(DragUpdateDetails dragDetails) {
    final Offset delta = dragDetails.globalPosition - _toolBarDragStart;
    _toolBarX = _toolBarStartPosition.dx + delta.dx;
    _toolBarY = _toolBarStartPosition.dy + delta.dy;

    // Keep panel within screen bounds
    _toolBarX = _toolBarX.clamp(16.0, _windowSize.width - 230 - 16.0);
    _toolBarY = _toolBarY.clamp(16.0, _windowSize.height - 200);

    setState(() {});
  }

  void _onPanStart(DragStartDetails dragDetails) async {
    if (_imageData == null && _excuting == false) {
      _excuting = true;
      await _captureScreen();
    }
  }

  void _onPanEnd(DragEndDetails dragDetails) {
    _imageData = null;
    setState(() {
      _isActive = false;
    });
  }

  void _searchPixel(Offset globalPosition) {
    _calculatePixel(globalPosition);
  }

  Future<void> _captureScreen() async {
    try {
      RenderRepaintBoundary boundary = FlutterAux.context!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _excuting = false;
        return;
      }
      _imageData = byteData.buffer.asUint8List();
      _excuting = false;
      image.dispose();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _calculatePixel(Offset globalPosition) async {
    if (_imageData == null) return;
    double px = globalPosition.dx;
    double py = globalPosition.dy;

    _currentColor = await getPixelColorFromBytes(_imageData!, px.toInt(), py.toInt()) ?? Colors.white;
  }

  /// 获取指定坐标的像素颜色
  Future<Color?> getPixelColorFromBytes(Uint8List bytes, int x, int y) async {
    final ui.Image image = await decodeImageFromList(bytes);

    final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) return null;

    final Uint8List pixels = data.buffer.asUint8List();

    // 每个像素4字节(RGBA)
    final int offset = (y * image.width + x) * 4;

    final int r = pixels[offset];
    final int g = pixels[offset + 1];
    final int b = pixels[offset + 2];
    final int a = pixels[offset + 3];

    return Color.fromARGB(a, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    if (_windowSize.isEmpty) {
      _windowSize = MediaQuery.of(context).size;
      _magnifierPosition = _windowSize.center(Offset.zero) -
          _magnifierSize.center(
            Offset.zero,
          );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        _buildColorInfoPanel(),
        _buildMagnifier(),
      ],
    );
  }

  Widget _buildColorInfoPanel() {
    return Positioned(
      left: _toolBarX,
      top: _toolBarY,
      child: GestureDetector(
        onPanStart: _toolBarPanStart,
        onPanUpdate: _toolBarPanUpdate,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2C3E50),
                const Color(0xFF34495E),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: _buildColorDisplay(),
        ),
      ),
    );
  }

  Widget _buildColorDisplay() {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildColorSample(),
          const SizedBox(height: 16),
          _buildColorInfo(),
          const SizedBox(height: 16),
          _buildColorValues(),
        ],
      ),
    );
  }

  Widget _buildColorSample() {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: _currentColor,
        border: Border.all(
          width: 2.0,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        boxShadow: [
          BoxShadow(
            color: _currentColor.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildColorInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: Text(
        "HEX #${_currentColor.value.toRadixString(16).substring(2).toUpperCase()}",
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildColorValues() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildColorValueRow('RGB', '${_currentColor.red}, ${_currentColor.green}, ${_currentColor.blue}'),
          const SizedBox(height: 8),
          _buildColorValueRow('Alpha', '${(_currentColor.alpha / 255 * 100).toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildColorValueRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildMagnifier() {
    return Positioned(
      left: _magnifierPosition.dx,
      top: _magnifierPosition.dy,
      child: ClipRRect(
        borderRadius: _radius!,
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanEnd: _onPanEnd,
          onPanUpdate: _onPanUpdate,
          child: BackdropFilter(
            filter: ui.ImageFilter.matrix(
              _matrix.storage,
              filterQuality: FilterQuality.none,
            ),
            child: Container(
              height: _magnifierSize.height,
              width: _magnifierSize.width,
              decoration: BoxDecoration(
                borderRadius: _radius!,
                border: Border.all(
                  color: _isActive ? const Color(0xFF3498DB) : Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isActive
                        ? const Color(0xFF3498DB).withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.3),
                    blurRadius: _isActive ? 15 : 10,
                    spreadRadius: _isActive ? 2 : 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 2,
                      width: 20,
                      decoration: BoxDecoration(
                        color: _isActive ? const Color(0xFF3498DB) : Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: 20,
                      width: 2,
                      decoration: BoxDecoration(
                        color: _isActive ? const Color(0xFF3498DB) : Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                        color: _isActive ? const Color(0xFF3498DB) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isActive ? Colors.white : const Color(0xFF2C3E50),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
