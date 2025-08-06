import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 图片轮播预加载管理器
///
/// 负责处理图片的预加载逻辑，支持缓存和非缓存模式。
/// 提供智能预加载功能，提升用户体验。
class ImageCarouselPreloadManager {
  /// 是否启用预加载
  final bool enablePreload;

  /// 预加载数量
  final int preloadCount;

  /// 是否启用缓存
  final bool enableCache;

  /// 图片列表
  final List<String> images;

  /// 创建预加载管理器实例
  ///
  /// [enablePreload] 是否启用预加载
  /// [preloadCount] 预加载数量
  /// [enableCache] 是否启用缓存
  /// [images] 图片列表
  const ImageCarouselPreloadManager({
    required this.enablePreload,
    required this.preloadCount,
    required this.enableCache,
    required this.images,
  });

  /// 预加载当前图片前后的图片
  ///
  /// [currentIndex] 当前图片索引
  /// [context] 构建上下文
  void preloadImages(int currentIndex, BuildContext context) {
    if (!enablePreload || images.isEmpty) return;

    for (int i = 1; i <= preloadCount; i++) {
      final int nextIndex = _getNextIndex(currentIndex, i);
      final int prevIndex = _getPreviousIndex(currentIndex, i);

      // 预加载下一张图片
      _preloadImage(nextIndex, context);
      // 预加载上一张图片
      _preloadImage(prevIndex, context);
    }
  }

  /// 预加载单张图片
  ///
  /// [index] 图片索引
  /// [context] 构建上下文
  void _preloadImage(int index, BuildContext context) {
    if (!_isValidIndex(index)) return;

    if (enableCache) {
      _preloadWithCache(index, context);
    } else {
      _preloadWithoutCache(index, context);
    }
  }

  /// 使用缓存模式预加载图片
  ///
  /// [index] 图片索引
  /// [context] 构建上下文
  void _preloadWithCache(int index, BuildContext context) {
    final imageProvider = CachedNetworkImageProvider(images[index]);
    precacheImage(imageProvider, context);
  }

  /// 不使用缓存模式预加载图片
  ///
  /// [index] 图片索引
  /// [context] 构建上下文
  void _preloadWithoutCache(int index, BuildContext context) {
    final imageProvider = NetworkImage(images[index]);
    precacheImage(imageProvider, context);
  }

  /// 获取下一个索引
  ///
  /// [currentIndex] 当前索引
  /// [offset] 偏移量
  /// 返回下一个索引，支持循环
  int _getNextIndex(int currentIndex, int offset) {
    return (currentIndex + offset) % images.length;
  }

  /// 获取上一个索引
  ///
  /// [currentIndex] 当前索引
  /// [offset] 偏移量
  /// 返回上一个索引，支持循环
  int _getPreviousIndex(int currentIndex, int offset) {
    return (currentIndex - offset + images.length) % images.length;
  }

  /// 检查索引是否有效
  ///
  /// [index] 要检查的索引
  /// 返回索引是否在有效范围内
  bool _isValidIndex(int index) {
    return index >= 0 && index < images.length;
  }
}
