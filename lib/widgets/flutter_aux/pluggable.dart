import 'package:flutter/widgets.dart';

abstract class Pluggable {
  String get name;

  Widget get display;

  Size get size;

  Offset get position;

  Widget build(BuildContext context);
}
