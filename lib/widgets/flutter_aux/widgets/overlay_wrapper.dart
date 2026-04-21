import 'package:flutter/material.dart';

import '../plugins/pluggable.dart';

/// 功能入口网格组件

class PluginOverlayWrapper extends StatelessWidget {
  const PluginOverlayWrapper({
    super.key,
    required this.child,
    required this.plugin,
    this.onBack,
    this.onClose,
  });

  final Widget child;

  final Pluggable plugin;

  final VoidCallback? onClose;

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          child,
          Positioned(
            right: 10,
            top: 0,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.withValues(alpha: 0.6),
                    ),
                    icon: Icon(Icons.remove),
                    onPressed: onBack,
                  ),
                  SizedBox(width: 5),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.withValues(alpha: 0.6),
                    ),
                    icon: Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
          ),
          if (plugin.tips.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    plugin.tips,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
