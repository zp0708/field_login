import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:field_login/widgets/flutter_aux/flutter_aux.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'pluggable.dart';

class ColorSucker extends Pluggable {
  @override
  String get name => 'ColorSucker';

  @override
  String get display => '颜色';

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return _ColorSucker();
  }

  @override
  bool get isOverlay => true;

  @override
  String get tips => '点击组件查看组件信息';
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
  double _toolBarY = 60.0;
  Matrix4 _matrix = Matrix4.identity();
  late Size _windowSize;
  bool _excuting = false;
  Uint8List? _imageData;

  @override
  void initState() {
    _windowSize = ui.window.physicalSize / ui.window.devicePixelRatio;
    _magnifierSize = Size(100, 100);
    _scale = 10;
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
    setState(() {});
  }

  void _toolBarPanUpdate(DragUpdateDetails dragDetails) {
    _toolBarY = dragDetails.globalPosition.dy - 40;
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
    Widget toolBar = Container(
      width: 240,
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
      margin: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentColor,
              border: Border.all(width: 2.0, color: Colors.white),
              boxShadow: [
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 40, right: 16),
            child: Text(
              "#${_currentColor.value.toRadixString(16).substring(2)}",
              style: const TextStyle(
                fontSize: 25,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 0,
          top: _toolBarY,
          child: GestureDetector(
            onVerticalDragUpdate: _toolBarPanUpdate,
            child: toolBar,
          ),
        ),
        Positioned(
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
                      color: Colors.grey,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      height: 1,
                      width: 1,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
