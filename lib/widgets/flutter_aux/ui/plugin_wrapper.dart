import 'package:field_login/widgets/flutter_aux/flutter_aux.dart';
import 'package:field_login/widgets/flutter_aux/pluggable.dart';
import 'package:flutter/material.dart';

/// 功能入口网格组件
class PluginWrapper extends StatefulWidget {
  final Pluggable plugin;
  final Offset position;
  final VoidCallback? onClose;
  final Widget child;

  const PluginWrapper({
    super.key,
    required this.child,
    required this.plugin,
    required this.position,
    this.onClose,
  });

  @override
  State<PluginWrapper> createState() => _PluginWrapperState();
}

class _PluginWrapperState extends State<PluginWrapper> {
  Offset _position = Offset.zero;
  bool _isDragging = false;
  Offset? _dragStartPosition;
  Offset? _overlayStartPosition;

  @override
  void initState() {
    _position = widget.position;
    super.initState();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragStartPosition = details.globalPosition;
      _overlayStartPosition = _position;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragStartPosition != null && _overlayStartPosition != null) {
      setState(() {
        // 计算手指移动的距离，直接应用到overlay位置
        _position = _overlayStartPosition! + (details.globalPosition - _dragStartPosition!);
      });
      // 更新 OverlayManager 中的位置
      OverlayManager.updatePosition(_position);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragStartPosition = null;
      _overlayStartPosition = null;
    });

    // 拖拽结束时保存位置
    OverlayManager.saveCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.plugin.size.width,
      height: widget.plugin.size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDragging ? 0.4 : 0.2),
            blurRadius: _isDragging ? 15 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 可拖动的标题栏
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isDragging ? Icons.drag_handle : Icons.grid_view,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.plugin.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Icon(
                      Icons.close,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // GridView 内容
          Flexible(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
