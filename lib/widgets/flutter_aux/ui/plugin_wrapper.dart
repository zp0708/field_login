import 'package:field_login/widgets/flutter_aux/flutter_aux.dart';
import 'package:field_login/widgets/flutter_aux/pluggable.dart';
import 'package:flutter/material.dart';

/// 功能入口网格组件
class PluginWrapper extends StatefulWidget {
  final Pluggable plugin;
  final Offset position;
  final Size size;
  final VoidCallback? onClose;
  final Widget child;

  const PluginWrapper({
    super.key,
    required this.child,
    required this.plugin,
    required this.position,
    required this.size,
    this.onClose,
  });

  @override
  State<PluginWrapper> createState() => _PluginWrapperState();
}

class _PluginWrapperState extends State<PluginWrapper> {
  Offset _position = Offset.zero;
  Size _size = Size.zero;
  bool _isDragging = false;
  bool _isResizing = false;
  Offset? _dragStartPosition;
  Offset? _overlayStartPosition;
  Size? _resizeStartSize;

  @override
  void initState() {
    _position = widget.position;
    _size = widget.size;
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
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragStartPosition = null;
      _overlayStartPosition = null;
    });

    // 拖拽结束时保存位置
    OverlayManager.savePosition(widget.plugin.name, _position);
  }

  // 大小调整相关方法
  void _onResizeStart(DragStartDetails details) {
    setState(() {
      _isResizing = true;
      _dragStartPosition = details.globalPosition;
      _resizeStartSize = _size;
    });
  }

  void _onResizeUpdate(DragUpdateDetails details) {
    if (_dragStartPosition != null && _resizeStartSize != null) {
      final delta = details.globalPosition - _dragStartPosition!;

      setState(() {
        // 计算新的大小，设置最小和最大限制
        final newWidth = (_resizeStartSize!.width + delta.dx).clamp(200.0, 800.0);
        final newHeight = (_resizeStartSize!.height + delta.dy).clamp(150.0, 600.0);
        _size = Size(newWidth, newHeight);
      });
    }
  }

  void _onResizeEnd(DragEndDetails details) {
    setState(() {
      _isResizing = false;
      _dragStartPosition = null;
      _resizeStartSize = null;
    });

    // 大小调整结束时保存大小
    OverlayManager.saveSize(widget.plugin.name, _size);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _position.dy,
      left: _position.dx,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: _size.width,
          height: _size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: (_isDragging || _isResizing) ? 0.4 : 0.2),
                blurRadius: (_isDragging || _isResizing) ? 15 : 10,
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
                child: Stack(
                  children: [
                    Positioned.fill(child: widget.child),
                    // 大小调整手柄 - 右下角
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onPanStart: _onResizeStart,
                        onPanUpdate: _onResizeUpdate,
                        onPanEnd: _onResizeEnd,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade300,
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Icon(
                            Icons.drag_handle,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
