import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../widgets/drag_position.dart';

class PluginBottom extends StatefulWidget {
  const PluginBottom({
    super.key,
    this.onBack,
    this.onClose,
  });

  final VoidCallback? onClose;

  final VoidCallback? onBack;

  @override
  State<PluginBottom> createState() => _PluginBottomState();
}

class _PluginBottomState extends State<PluginBottom> {
  String? _version;

  @override
  void initState() {
    _getVersion();
    super.initState();
  }

  Future<void> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DragReset(
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Icon(
              Icons.refresh,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
        Spacer(),
        Text(
          _version ?? '',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade300,
          ),
        ),
        Spacer(),
        // 大小调整手柄 - 右下角
        DragResize(
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue.shade300,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: Icon(
              Icons.drag_handle,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
