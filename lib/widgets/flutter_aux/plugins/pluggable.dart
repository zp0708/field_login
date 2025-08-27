import 'package:flutter/widgets.dart';

abstract class Pluggable {
  String get name;

  String get display;

  Size get size;

  Widget build(BuildContext context);

  /// true 的时候是显示 overlay 模式
  bool get isOverlay => false;

  String get tips => '';
}
