import 'package:flutter/material.dart';
import '../models/carousel_options.dart';

/// 图片轮播手势处理器
///
/// 负责处理图片的手势交互，包括点击、缩放等功能。
/// 提供统一的手势处理接口，支持自定义手势行为。
class ImageCarouselGestureHandler extends StatelessWidget {
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
  Widget build(BuildContext context) {
    Widget wrappedChild = child;

    // 添加缩放功能
    if (options.enableZoom) {
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
      minScale: options.minScale,
      maxScale: options.maxScale,
      constrained: true,
      child: child,
    );
  }

  /// 构建手势检测器
  ///
  /// [child] 子组件
  /// 返回手势检测器组件
  Widget _buildGestureDetector(Widget child) {
    if (options.enableGestureControl) {
      return GestureDetector(
        onTap: () => _handleImageTap(),
        onDoubleTap: options.enableZoom ? _handleDoubleTap : null,
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
    onImageTap?.call(image, index);
  }

  /// 处理双击
  void _handleDoubleTap() {
    // 双击缩放功能可以在这里实现
    // 目前使用InteractiveViewer的默认行为
  }
}
