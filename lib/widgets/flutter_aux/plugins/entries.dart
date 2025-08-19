import 'package:field_login/widgets/flutter_aux/flutter_aux.dart';
import 'package:field_login/widgets/flutter_aux/pluggable.dart';
import 'package:flutter/material.dart';

class Entries extends Pluggable {
  @override
  String get name => 'entries';

  @override
  Widget get display => const Text('entries');

  @override
  Size get size => const Size(300, 300);

  @override
  Widget build(BuildContext context) {
    return FunctionGridOverlay(plugins: OverlayManager.plugins, plugin: this);
  }
}

/// 功能入口网格组件
class FunctionGridOverlay extends StatelessWidget {
  final Pluggable plugin;
  final List<Pluggable> plugins;

  const FunctionGridOverlay({
    super.key,
    required this.plugins,
    required this.plugin,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: plugins.length,
      itemBuilder: (context, index) {
        final entry = plugins[index];
        return GestureDetector(
          onTap: () {
            OverlayManager.showPlugin(context, entry);
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.yellow.withAlpha(50),
                width: 1,
              ),
            ),
            child: entry.display,
          ),
        );
      },
    );
  }
}
