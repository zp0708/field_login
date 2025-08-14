import 'package:flutter/material.dart';
import '../models/carousel_options.dart';

/// 图片轮播手势处理器
///
/// 负责处理图片的手势交互，包括点击、缩放等功能。
/// 提供统一的手势处理接口，支持自定义手势行为。
class ImageCarouselGestureHandler extends StatefulWidget {
  /// 配置选项
  final ImageCarouselOptions options;

  /// 子组件
  final Widget child;

  /// 图片URL
  final String image;

  /// 图片索引
  final int index;

  /// 图片点击回调
  final void Function(String image, int index)? onImageTap;

  /// 创建手势处理器实例
  ///
  /// [options] 配置选项
  /// [child] 子组件
  /// [image] 图片URL
  /// [index] 图片索引
  /// [onImageTap] 图片点击回调
  const ImageCarouselGestureHandler({
    super.key,
    required this.options,
    required this.child,
    required this.image,
    required this.index,
    this.onImageTap,
  });

  @override
  State<ImageCarouselGestureHandler> createState() => _ImageCarouselGestureHandlerState();
}

class _ImageCarouselGestureHandlerState extends State<ImageCarouselGestureHandler> with TickerProviderStateMixin {
  /// 变换控制器
  late TransformationController _transformationController;

  /// 动画控制器
  late AnimationController _animationController;

  /// 动画
  late Animation<double> _animation;

  /// 当前是否处于放大状态
  bool _isZoomed = false;

  /// 双击目标缩放比例
  late double _doubleTapScale;

  /// 双击位置
  Offset? _doubleTapPosition;

  @override
  void initState() {
    super.initState();

    // 初始化变换控制器
    _transformationController = TransformationController();

    // 初始化动画控制器
    _animationController = AnimationController(
      duration: widget.options.doubleTapZoomDuration,
      vsync: this,
    );

    // 计算双击目标缩放比例
    _doubleTapScale = widget.options.doubleTapScale ?? (widget.options.minScale + widget.options.maxScale) / 2;

    // 设置动画
    _animation = Tween<double>(
      begin: 1.0,
      end: _doubleTapScale,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.options.doubleTapZoomCurve,
    ));

    // 监听动画状态变化
    _animationController.addStatusListener(_onAnimationStatusChanged);

    // 监听动画值变化，实时更新缩放
    _animationController.addListener(_onAnimationValueChanged);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget wrappedChild = widget.child;

    // 添加缩放功能
    if (widget.options.enableZoom) {
      wrappedChild = _buildInteractiveViewer(wrappedChild);
    }

    // 添加手势控制
    wrappedChild = _buildGestureDetector(wrappedChild);

    return wrappedChild;
  }

  /// 构建交互式查看器
  ///
  /// [child] 子组件
  /// 返回交互式查看器组件
  Widget _buildInteractiveViewer(Widget child) {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: widget.options.minScale,
      maxScale: widget.options.maxScale,
      constrained: true,
      onInteractionEnd: _onInteractionEnd,
      child: child,
    );
  }

  /// 构建手势检测器
  ///
  /// [child] 子组件
  /// 返回手势检测器组件
  Widget _buildGestureDetector(Widget child) {
    if (widget.options.enableGestureControl) {
      return GestureDetector(
        onTap: () => _handleImageTap(),
        onDoubleTapDown:
            (widget.options.enableZoom && widget.options.enableDoubleTapZoom) ? _handleDoubleTapDown : null,
        onDoubleTap: (widget.options.enableZoom && widget.options.enableDoubleTapZoom) ? _handleDoubleTap : null,
        child: child,
      );
    } else {
      return GestureDetector(
        onTap: () => _handleImageTap(),
        child: child,
      );
    }
  }

  /// 处理图片点击
  void _handleImageTap() {
    widget.onImageTap?.call(widget.image, widget.index);
  }

  /// 处理双击按下
  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapPosition = details.localPosition;
  }

  /// 处理双击
  void _handleDoubleTap() {
    if (!widget.options.enableZoom || !widget.options.enableDoubleTapZoom) return;

    if (_isZoomed) {
      // 如果当前是放大状态，则恢复到原始大小
      _resetZoom();
    } else {
      // 如果当前是原始大小，则放大到目标比例
      _zoomToTarget();
    }
  }

  /// 放大到目标比例
  void _zoomToTarget() {
    if (_animationController.isAnimating) return;

    // 如果有双击位置，计算缩放中心点
    if (_doubleTapPosition != null) {
      _calculateZoomCenter();
    }

    _animationController.forward();
  }

  /// 重置缩放
  void _resetZoom() {
    if (_animationController.isAnimating) return;

    _animationController.reverse();
  }

  /// 计算缩放中心点
  void _calculateZoomCenter() {
    if (_doubleTapPosition == null) return;

    // 获取当前视图大小
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 计算双击位置相对于中心的偏移
    final offsetX = _doubleTapPosition!.dx - centerX;
    final offsetY = _doubleTapPosition!.dy - centerY;

    // 创建变换矩阵，以双击位置为中心进行缩放
    final matrix = Matrix4.identity()
      ..translate(-offsetX, -offsetY)
      ..scale(_doubleTapScale)
      ..translate(offsetX, offsetY);

    // 应用变换
    _transformationController.value = matrix;
  }

  /// 监听动画值变化
  void _onAnimationValueChanged() {
    if (_doubleTapPosition != null && _animationController.isAnimating) {
      // 如果正在动画且有点击位置，使用计算的中心点
      return;
    }

    // 否则使用简单的缩放
    final scale = _animation.value;
    _transformationController.value = Matrix4.identity()..scale(scale);
  }

  /// 监听动画状态变化
  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // 动画完成，设置为放大状态
      setState(() {
        _isZoomed = true;
      });
    } else if (status == AnimationStatus.dismissed) {
      // 动画取消，设置为原始状态
      setState(() {
        _isZoomed = false;
      });
    }
  }

  /// 监听交互结束
  void _onInteractionEnd(ScaleEndDetails details) {
    // 检查是否需要重置到边界
    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();

    if (scale < widget.options.minScale) {
      // 如果缩放比例小于最小值，重置到最小值
      _transformationController.value = Matrix4.identity()..scale(widget.options.minScale);
      setState(() {
        _isZoomed = false;
      });
    } else if (scale > widget.options.maxScale) {
      // 如果缩放比例大于最大值，重置到最大值
      _transformationController.value = Matrix4.identity()..scale(widget.options.maxScale);
      setState(() {
        _isZoomed = true;
      });
    }
  }

  /// 重置到原始状态
  void resetToOriginal() {
    if (_animationController.isAnimating) return;

    _transformationController.value = Matrix4.identity();
    setState(() {
      _isZoomed = false;
    });
  }

  /// 获取当前缩放比例
  double getCurrentScale() {
    final matrix = _transformationController.value;
    return matrix.getMaxScaleOnAxis();
  }

  /// 检查是否处于放大状态
  bool get isZoomed => _isZoomed;

  /// 检查是否可以进一步放大
  bool get canZoomIn {
    final currentScale = getCurrentScale();
    return currentScale < widget.options.maxScale;
  }

  /// 检查是否可以进一步缩小
  bool get canZoomOut {
    final currentScale = getCurrentScale();
    return currentScale > widget.options.minScale;
  }
}
