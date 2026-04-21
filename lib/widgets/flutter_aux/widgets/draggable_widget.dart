import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraggableScope extends InheritedWidget {
  final DraggableWidgetState state;

  const DraggableScope({
    super.key,
    required this.state,
    required super.child,
  });

  // 提供一个便捷的方法给子组件调用
  static DraggableWidgetState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DraggableScope>();
    assert(scope != null, 'Drag 组件必须放在 TransformContainer 内部!');
    return scope!.state;
  }

  @override
  bool updateShouldNotify(DraggableScope oldWidget) => true;
}

/// 可拖动组件
class DraggableWidget extends StatefulWidget {
  const DraggableWidget({
    super.key,
    required this.child,
    required this.rect,
    this.cacheKey,
    this.useDecoration = true,
  });

  final Widget child;

  /// 缓存的 key, 为 null 的时候不保存
  final String? cacheKey;

  final Rect rect;

  /// 是否使用默认的装饰
  final bool useDecoration;

  @override
  State<DraggableWidget> createState() => DraggableWidgetState();
}

class DraggableWidgetState extends State<DraggableWidget> {
  Rect _rect = Rect.zero;
  bool _isDragging = false;

  String? _cacheKey;

  @override
  void initState() {
    if (widget.cacheKey != null) _cacheKey = 'flutter_aux_plugin_rect_${widget.cacheKey}';
    _onShow();
    super.initState();
  }

  void _onShow() async {
    _rect = await _getRect();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void start(Offset delta) {
    setState(() => _isDragging = true);
  }

  void reset() async {
    await _reset();
    final rect = await _getRect();
    _rect = rect;
    setState(() {});
  }

  void end(Offset delta) {
    setState(() => _isDragging = false);
    _save(_rect);
  }

  // 移动逻辑（包含边界限制）
  void move(Offset delta) {
    setState(() {
      Rect newRect = _rect.shift(delta);
      final screenSize = MediaQuery.sizeOf(context);
      // 确保不超出父容器四周边界
      double left = newRect.left.clamp(-_rect.width + 120, math.max(0.0, screenSize.width - 100));
      double top = newRect.top.clamp(
        0.0,
        math.max(0.0, screenSize.height - math.min(50, _rect.height)),
      );

      _rect = Rect.fromLTWH(left, top, _rect.width, _rect.height);
    });
  }

  // 右下角缩放逻辑（包含边界限制）
  void resize(Offset delta) {
    setState(() {
      final screenSize = MediaQuery.sizeOf(context);
      // 算出往右、往下拖拽的最大极限
      double maxWidth = screenSize.width - _rect.left;
      double maxHeight = screenSize.height - _rect.top;

      // 确保宽高不小于设定最小值，且不超出父容器边界
      double newWidth = (_rect.width + delta.dx).clamp(100, math.max(200, maxWidth));
      double newHeight = (_rect.height + delta.dy).clamp(100, math.max(200, maxHeight));

      _rect = Rect.fromLTWH(_rect.left, _rect.top, newWidth, newHeight);
    });
  }

  @override
  void didUpdateWidget(DraggableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rect != oldWidget.rect) {
      _rect = widget.rect;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = DraggableScope(
      state: this,
      child: widget.child,
    );
    return Positioned(
      left: _rect.left,
      top: _rect.top,
      width: _rect.width,
      height: _rect.height,
      child: Material(
        color: Colors.transparent,
        child: widget.useDecoration
            ? Container(
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.hardEdge,
                  child: scope,
                ),
              )
            : scope,
      ),
    );
  }

  /// 将 Rect 压缩为一个 String 后保存到 SharedPreferences
  Future<void> _save(Rect rect) async {
    if (_cacheKey == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(
        _cacheKey!,
        '${rect.left.toInt()},${rect.top.toInt()},${rect.width.toInt()},${rect.height.toInt()}',
      );
    } catch (e) {
      // 忽略异常（例如 web 存储异常）
    }
  }

  /// 从 SharedPreferences 中读取 Rect
  Future<Rect> _getRect() async {
    if (_cacheKey == null) return widget.rect;
    try {
      final prefs = await SharedPreferences.getInstance();
      final packed = prefs.getString(_cacheKey!);
      // 没有缓存数据
      if (packed == null) return widget.rect;
      final list = packed.split(',');

      return Rect.fromLTWH(
        double.parse(list[0]),
        double.parse(list[1]),
        double.parse(list[2]),
        double.parse(list[3]),
      );
    } catch (e) {
      // 读取失败时返回 null
    }

    return Rect.zero;
  }

  /// 保存当前位置
  Future<void> _reset() async {
    if (_cacheKey == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove(_cacheKey!);
    } catch (e) {
      // 忽略错误
    }
  }
}
