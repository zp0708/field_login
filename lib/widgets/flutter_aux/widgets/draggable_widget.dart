import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../plugins/pluggable.dart';

/// 可拖动组件
class DraggableWidget extends StatefulWidget {
  const DraggableWidget({
    super.key,
    required this.child,
    required this.plugin,
  });

  final Widget child;

  final Pluggable plugin;

  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> {
  Offset _position = Offset.zero;
  Size _size = Size.zero;
  bool _isDragging = false;
  bool _isResizing = false;
  Offset? _dragStartPosition;
  Offset? _overlayStartPosition;
  Size? _resizeStartSize;
  Size _screenSize = Size.zero;

  @override
  void initState() {
    _onShow();
    super.initState();
  }

  void _onShow() async {
    final position = await _getSavedPosition() ?? Offset(50, 50);
    final size = await _getSavedSize() ?? widget.plugin.size;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _screenSize = MediaQuery.of(context).size;
        _position = position;
        _size = size;
      });
    });
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
        // 确保 panel 可见
        final dx = _position.dx.clamp(-_size.width + 20.0, _screenSize.width - 20.0);
        final dy = _position.dy.clamp(0.0, _screenSize.height - 20.0);
        _position = Offset(dx, dy);
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
    _savePosition(_position);
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
        final newWidth = (_resizeStartSize!.width + delta.dx).clamp(200.0, 1000.0);
        final newHeight = (_resizeStartSize!.height + delta.dy).clamp(200.0, 1000.0);
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
    _saveSize(_size);
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
          clipBehavior: Clip.hardEdge,
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
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      Icon(
                        _isDragging ? Icons.drag_handle : Icons.grid_view,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.plugin.display,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      Spacer(),
                      InkWell(
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
                      InkWell(
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
                ),
              ),
              // GridView 内容
              Flexible(
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      bottom: 20,
                      right: 0,
                      child: Container(color: Colors.red, child: widget.plugin.build(context)),
                    ),
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

  /// 获取保存的位置
  Future<Offset?> _getSavedPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final x = prefs.getDouble('overlay_position_${widget.plugin.name}_x');
      final y = prefs.getDouble('overlay_position_${widget.plugin.name}_y');
      if (x != null && y != null) {
        return Offset(x, y);
      }
    } catch (e) {
      // 忽略错误，返回 null
    }
    return null;
  }

  /// 保存当前位置
  Future<void> _savePosition(Offset position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('overlay_position_${widget.plugin.name}_x', position.dx);
      await prefs.setDouble('overlay_position_${widget.plugin.name}_y', position.dy);
    } catch (e) {
      // 忽略错误
    }
  }

  /// 获取保存的大小
  Future<Size?> _getSavedSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final width = prefs.getDouble('overlay_size_${widget.plugin.name}_width');
      final height = prefs.getDouble('overlay_size_${widget.plugin.name}_height');
      if (width != null && height != null) {
        return Size(width, height);
      }
    } catch (e) {
      // 忽略错误，返回 null
    }
    return null;
  }

  /// 保存大小
  Future<void> _saveSize(Size size) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('overlay_size_${widget.plugin.name}_width', size.width);
      await prefs.setDouble('overlay_size_${widget.plugin.name}_height', size.height);
    } catch (e) {
      // 忽略错误
    }
  }
}
