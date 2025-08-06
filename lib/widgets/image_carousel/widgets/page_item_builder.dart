import 'package:flutter/material.dart';
import 'image_builder.dart';
import 'gesture_handler.dart';
import '../managers/error_manager.dart';
import '../models/carousel_options.dart';

/// 页面项构建器
///
/// 负责构建单个页面项，支持自定义图片构建器和手势处理。
/// 提供统一的页面项构建接口，避免代码重复。
class PageItemBuilder extends StatelessWidget {
  /// 图片URL
  final String image;

  /// 图片索引
  final int index;

  /// 配置选项
  final ImageCarouselOptions options;

  /// 错误管理器
  final ImageCarouselErrorManager errorManager;

  // UI相关参数
  /// 占位符组件
  final Widget? placeholder;

  /// 错误组件
  final Widget? errorWidget;

  /// 图片点击回调
  final void Function(String image, int index)? onImageTap;

  /// 自定义图片构建器
  final Widget? Function(String image, int index)? imageBuilder;

  /// 创建页面项构建器实例
  ///
  /// [image] 图片URL
  /// [index] 图片索引
  /// [options] 配置选项
  /// [errorManager] 错误管理器
  /// [placeholder] 占位符组件
  /// [errorWidget] 错误组件
  /// [onImageTap] 图片点击回调
  /// [imageBuilder] 自定义图片构建器
  const PageItemBuilder({
    super.key,
    required this.image,
    required this.index,
    required this.options,
    required this.errorManager,
    this.placeholder,
    this.errorWidget,
    this.onImageTap,
    this.imageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageBuilder != null) {
      final Widget? customWidget = imageBuilder!(image, index);
      if (customWidget != null) {
        return ImageCarouselGestureHandler(
          options: options,
          image: image,
          index: index,
          onImageTap: onImageTap,
          child: customWidget,
        );
      }
    }

    return ImageCarouselGestureHandler(
      options: options,
      image: image,
      index: index,
      onImageTap: onImageTap,
      child: ImageCarouselImageBuilder(
        options: options,
        errorManager: errorManager,
        image: image,
        index: index,
        placeholder: placeholder,
        errorWidget: errorWidget,
      ),
    );
  }
}
