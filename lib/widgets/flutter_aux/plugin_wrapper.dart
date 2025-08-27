import 'package:flutter/material.dart';
import 'plugins/pluggable.dart';
import 'flutter_aux.dart';

/// 功能入口网格组件
class PluginWrapper extends StatefulWidget {
  final Pluggable plugin;
  final Offset position;
  final Size size;
  final VoidCallback? onClose;
  final Widget child;
  final bool showReset;

  const PluginWrapper({
    super.key,
    required this.child,
    required this.plugin,
    required this.position,
    required this.size,
    this.onClose,
    this.showReset = false,
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
  Size _screenSize = Size.zero;

  @override
  void initState() {
    _position = widget.position;
    _size = widget.size;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _screenSize = MediaQuery.of(context).size;
    });
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
    FlutterAux.savePosition(widget.plugin.name, _position);
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
    FlutterAux.saveSize(widget.plugin.name, _size);
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
                      const Spacer(),
                      InkWell(
                        onTap: widget.onClose,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
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
                    // reset 按钮
                    if (widget.showReset)
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () {
                            FlutterAux.resetPlugins();
                            setState(() {
                              _size = widget.plugin.size;
                            });
                          },
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
                      )
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

class PluginOverlayWrapper extends StatelessWidget {
  final Widget child;
  final Pluggable plugin;
  const PluginOverlayWrapper({
    super.key,
    required this.child,
    required this.plugin,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          child,
          Positioned(
            left: 20,
            bottom: 20,
            child: Center(
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                ),
                icon: Icon(Icons.close),
                onPressed: () => FlutterAux.showEntries(),
              ),
            ),
          ),
          if (plugin.tips.isNotEmpty)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  plugin.tips,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            )
        ],
      ),
    );
  }
}
