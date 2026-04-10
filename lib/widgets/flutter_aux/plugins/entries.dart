import 'package:flutter/material.dart';
import 'pluggable.dart';
import '../flutter_aux.dart';

class Entries extends Pluggable {
  Entries({required this.onPlugin});

  final ValueChanged<Pluggable> onPlugin;

  @override
  String get name => 'entries';

  @override
  String get display => '辅助工具';

  @override
  Size get size => const Size(230, 520);

  @override
  Widget build(BuildContext context) {
    return FunctionGridOverlay(
      plugins: FlutterAux.plugins,
      plugin: this,
      onPlugin: onPlugin,
    );
  }
}

/// 功能入口网格组件
class FunctionGridOverlay extends StatelessWidget {
  final Pluggable plugin;
  final List<Pluggable> plugins;

  final ValueChanged<Pluggable> onPlugin;

  const FunctionGridOverlay({
    super.key,
    required this.plugins,
    required this.plugin,
    required this.onPlugin,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          plugins.length,
          (idx) {
            final entry = plugins[idx];
            return GestureDetector(
              onTap: () => onPlugin(entry),
              child: Container(
                width: 100,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.yellow.withAlpha(50),
                    width: 1,
                  ),
                ),
                child: Text(entry.display),
              ),
            );
          },
        ),
      ),
    );
  }
}
