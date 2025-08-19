import 'package:flutter/widgets.dart';

abstract class Pluggable {
  String get name;

  String get display;

  Size get size;

  Widget build(BuildContext context);
}
