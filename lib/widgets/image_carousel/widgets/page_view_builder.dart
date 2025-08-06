import 'package:flutter/material.dart';
import '../managers/error_manager.dart';
import '../models/carousel_options.dart';
import 'page_item_builder.dart';

/// 无限滚动页面构建器
///
/// 负责构建无限滚动的页面视图，支持自动循环播放。
class InfinitePageViewBuilder extends StatelessWidget {
  /// 页面控制器
  final PageController controller;

  /// 图片列表
  final List<String> images;

  /// 页面变化回调
  final void Function(int) onPageChanged;

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

  /// 创建无限滚动页面构建器实例
  ///
  /// [controller] 页面控制器
  /// [images] 图片列表
  /// [onPageChanged] 页面变化回调
  /// [options] 配置选项
  /// [errorManager] 错误管理器
  /// [placeholder] 占位符组件
  /// [errorWidget] 错误组件
  /// [onImageTap] 图片点击回调
  /// [imageBuilder] 自定义图片构建器
  const InfinitePageViewBuilder({
    super.key,
    required this.controller,
    required this.images,
    required this.onPageChanged,
    required this.options,
    required this.errorManager,
    this.placeholder,
    this.errorWidget,
    this.onImageTap,
    this.imageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      onPageChanged: onPageChanged,
      itemCount: null, // 使用null表示无限滚动
      itemBuilder: (BuildContext context, int index) {
        final int actualIndex = index % images.length;
        return PageItemBuilder(
          image: images[actualIndex],
          index: actualIndex,
          options: options,
          errorManager: errorManager,
          placeholder: placeholder,
          errorWidget: errorWidget,
          onImageTap: onImageTap,
          imageBuilder: imageBuilder,
        );
      },
    );
  }
}

/// 普通页面构建器
///
/// 负责构建普通的页面视图，不支持循环播放。
class NormalPageViewBuilder extends StatelessWidget {
  /// 页面控制器
  final PageController controller;

  /// 图片列表
  final List<String> images;

  /// 页面变化回调
  final void Function(int) onPageChanged;

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

  /// 创建普通页面构建器实例
  ///
  /// [controller] 页面控制器
  /// [images] 图片列表
  /// [onPageChanged] 页面变化回调
  /// [options] 配置选项
  /// [errorManager] 错误管理器
  /// [placeholder] 占位符组件
  /// [errorWidget] 错误组件
  /// [onImageTap] 图片点击回调
  /// [imageBuilder] 自定义图片构建器
  const NormalPageViewBuilder({
    super.key,
    required this.controller,
    required this.images,
    required this.onPageChanged,
    required this.options,
    required this.errorManager,
    this.placeholder,
    this.errorWidget,
    this.onImageTap,
    this.imageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      onPageChanged: onPageChanged,
      itemCount: images.length,
      itemBuilder: (BuildContext context, int index) {
        return PageItemBuilder(
          image: images[index],
          index: index,
          options: options,
          errorManager: errorManager,
          placeholder: placeholder,
          errorWidget: errorWidget,
          onImageTap: onImageTap,
          imageBuilder: imageBuilder,
        );
      },
    );
  }
}

/// 单页面构建器
///
/// 负责构建单个页面的视图，用于只有一张图片的情况。
class SinglePageBuilder extends StatelessWidget {
  /// 图片URL
  final String image;

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

  /// 创建单页面构建器实例
  ///
  /// [image] 图片URL
  /// [options] 配置选项
  /// [errorManager] 错误管理器
  /// [placeholder] 占位符组件
  /// [errorWidget] 错误组件
  /// [onImageTap] 图片点击回调
  /// [imageBuilder] 自定义图片构建器
  const SinglePageBuilder({
    super.key,
    required this.image,
    required this.options,
    required this.errorManager,
    this.placeholder,
    this.errorWidget,
    this.onImageTap,
    this.imageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return PageItemBuilder(
      image: image,
      index: 0,
      options: options,
      errorManager: errorManager,
      placeholder: placeholder,
      errorWidget: errorWidget,
      onImageTap: onImageTap,
      imageBuilder: imageBuilder,
    );
  }
}
