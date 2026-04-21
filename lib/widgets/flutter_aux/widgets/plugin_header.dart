import 'package:flutter/material.dart';

import '../plugins/pluggable.dart';

class PluginHeader extends StatelessWidget {
  const PluginHeader({
    super.key,
    required this.plugin,
    this.onBack,
    this.onClose,
  });

  final Pluggable plugin;

  final VoidCallback? onClose;

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 10),
          Icon(
            Icons.grid_view,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            plugin.display,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          Spacer(),
          if (onBack != null)
            InkWell(
              onTap: onBack,
              child: SizedBox(
                height: 44,
                width: 44,
                child: Icon(
                  Icons.remove,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
            ),
          if (onClose != null)
            InkWell(
              onTap: onClose,
              child: SizedBox(
                height: 44,
                width: 44,
                child: Icon(
                  Icons.close,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
