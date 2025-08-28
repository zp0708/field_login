import 'package:flutter/material.dart';
import 'pluggable.dart';

class Performance extends Pluggable {
  @override
  String get name => 'Performance';

  @override
  String get display => '性能';

  @override
  Size get size => const Size(600, 260);

  @override
  Widget build(BuildContext context) {
    return _PerformancePage();
  }
}

class _PerformancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
        bottom: 20,
      ),
      child: PerformanceOverlay.allEnabled(),
    );
  }
}
