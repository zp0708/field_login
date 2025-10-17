import 'package:flutter/material.dart';

// 在组件下方显示一个overlay
// overlay 的宽度为组件的宽度
// 支持 overlay 在 ScrollView 随组件滚动
// AnchorOverlay(
//   showOverlay: showOverlay,
//   overlayBuilder: (context) => Text('overlay'),
//   child: TextField(
//     onChanged: (v) => setState((){_showOverlay = v.isNotEmpty;}),
//   )
// ),
class AnchorOverlay extends StatefulWidget {
  final Widget child;
  final bool showOverlay;
  final WidgetBuilder overlayBuilder;
  final Offset offset;
  final BoxConstraints? overlayConstraints; // 允许自定义浮层的额外约束（如最大高度）

  const AnchorOverlay({
    super.key,
    required this.child,
    required this.showOverlay,
    required this.overlayBuilder,
    this.offset = Offset.zero,
    this.overlayConstraints,
  });

  @override
  State<AnchorOverlay> createState() => _AnchorOverlayState();
}

class _AnchorOverlayState extends State<AnchorOverlay> with WidgetsBindingObserver {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _targetKey = GlobalKey();

  OverlayEntry? _overlayEntry;
  double? _targetWidth;
  double _targetHeight = 0;
  Size? _lastMeasuredSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.showOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showOverlay();
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnchorOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showOverlay != oldWidget.showOverlay) {
      if (widget.showOverlay) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showOverlay();
        });
      } else {
        _hideOverlay();
      }
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // 当窗口尺寸变化（如旋转/键盘弹出）时，下一帧再测量并刷新，避免读取到未稳定的尺寸
    if (_overlayEntry != null && widget.showOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _updateTargetSize(markNeedsBuild: true);
      });
    }
  }

  void _updateTargetSize({bool markNeedsBuild = false}) {
    final renderBox = _targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    final size = renderBox.size;
    _targetWidth = size.width;
    _targetHeight = size.height;
    if (_lastMeasuredSize != size) {
      _lastMeasuredSize = size;
      if (markNeedsBuild) {
        _overlayEntry?.markNeedsBuild();
      }
    }
  }

  void _showOverlay() {
    final renderBox = _targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.showOverlay) {
          _showOverlay();
        }
      });
      return;
    }

    final size = renderBox.size;
    _targetWidth = size.width;
    _targetHeight = size.height;
    _lastMeasuredSize = size;

    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild(); // 更新
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: _targetWidth,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(widget.offset.dx, _targetHeight + widget.offset.dy),
            child: Material(
              child: ConstrainedBox(
                constraints: _buildOverlayConstraints(),
                child: widget.overlayBuilder(context),
              ),
            ),
          ),
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _overlayEntry != null) {
        Overlay.of(context).insert(_overlayEntry!);
      }
    });
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    // 在每一帧构建后，如果浮层显示中，则检测宿主尺寸变化并刷新
    if (widget.showOverlay && _overlayEntry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _updateTargetSize(markNeedsBuild: true);
      });
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: KeyedSubtree(
        key: _targetKey,
        child: widget.child,
      ),
    );
  }

  BoxConstraints _buildOverlayConstraints() {
    final base = BoxConstraints(
      minWidth: 0,
      maxWidth: _targetWidth ?? 300,
    );
    final extra = widget.overlayConstraints;
    return extra == null ? base : base.enforce(extra);
  }
}
