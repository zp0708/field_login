import 'package:flutter/material.dart';

/// 图片轮播器配置选项
///
/// 封装轮播器的核心功能配置参数，UI相关配置通过主组件参数传递。
class ImageCarouselOptions {
  /// 是否启用缓存
  final bool enableCache;

  /// 是否启用错误重试
  final bool enableErrorRetry;

  /// 最大重试次数
  final int maxRetryCount;

  /// 重试延迟时间
  final Duration retryDelay;

  /// 图片适配方式
  final BoxFit fit;

  /// 是否启用Hero动画
  final bool enableHeroAnimation;

  /// Hero标签前缀
  final String? heroTagPrefix;

  /// 是否启用手势控制
  final bool enableGestureControl;

  /// 是否启用缩放
  final bool enableZoom;

  /// 最小缩放比例
  final double minScale;

  /// 最大缩放比例
  final double maxScale;

  // 新增配置选项
  /// 是否自动播放
  final bool autoPlay;

  /// 自动播放间隔
  final Duration autoPlayInterval;

  /// 是否启用无限滚动
  final bool infiniteScroll;

  /// 是否启用预加载
  final bool enablePreload;

  /// 预加载数量
  final int preloadCount;

  /// 高度
  final double? height;

  /// 宽度
  final double? width;

  /// 创建轮播器配置选项实例
  ///
  /// [enableCache] 是否启用缓存
  /// [enableErrorRetry] 是否启用错误重试
  /// [maxRetryCount] 最大重试次数
  /// [retryDelay] 重试延迟时间
  /// [fit] 图片适配方式
  /// [enableHeroAnimation] 是否启用Hero动画
  /// [heroTagPrefix] Hero标签前缀
  /// [enableGestureControl] 是否启用手势控制
  /// [enableZoom] 是否启用缩放
  /// [minScale] 最小缩放比例
  /// [maxScale] 最大缩放比例
  /// [autoPlay] 是否自动播放
  /// [autoPlayInterval] 自动播放间隔
  /// [infiniteScroll] 是否启用无限滚动
  /// [enablePreload] 是否启用预加载
  /// [preloadCount] 预加载数量
  /// [height] 高度
  /// [width] 宽度
  const ImageCarouselOptions({
    this.enableCache = true,
    this.enableErrorRetry = true,
    this.maxRetryCount = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.fit = BoxFit.cover,
    this.enableHeroAnimation = false,
    this.heroTagPrefix,
    this.enableGestureControl = true,
    this.enableZoom = false,
    this.minScale = 0.5,
    this.maxScale = 3.0,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.infiniteScroll = true,
    this.enablePreload = true,
    this.preloadCount = 2,
    this.height,
    this.width,
  });

  /// 创建默认配置选项
  ///
  /// 返回使用默认值的配置选项
  const ImageCarouselOptions.defaults()
      : enableCache = true,
        enableErrorRetry = true,
        maxRetryCount = 3,
        retryDelay = const Duration(seconds: 2),
        fit = BoxFit.cover,
        enableHeroAnimation = false,
        heroTagPrefix = null,
        enableGestureControl = true,
        enableZoom = false,
        minScale = 0.5,
        maxScale = 3.0,
        autoPlay = false,
        autoPlayInterval = const Duration(seconds: 3),
        infiniteScroll = true,
        enablePreload = true,
        preloadCount = 2,
        height = null,
        width = null;

  /// 复制并修改配置选项
  ///
  /// [enableCache] 是否启用缓存
  /// [enableErrorRetry] 是否启用错误重试
  /// [maxRetryCount] 最大重试次数
  /// [retryDelay] 重试延迟时间
  /// [fit] 图片适配方式
  /// [enableHeroAnimation] 是否启用Hero动画
  /// [heroTagPrefix] Hero标签前缀
  /// [enableGestureControl] 是否启用手势控制
  /// [enableZoom] 是否启用缩放
  /// [minScale] 最小缩放比例
  /// [maxScale] 最大缩放比例
  /// [autoPlay] 是否自动播放
  /// [autoPlayInterval] 自动播放间隔
  /// [infiniteScroll] 是否启用无限滚动
  /// [enablePreload] 是否启用预加载
  /// [preloadCount] 预加载数量
  /// [height] 高度
  /// [width] 宽度
  ImageCarouselOptions copyWith({
    bool? enableCache,
    bool? enableErrorRetry,
    int? maxRetryCount,
    Duration? retryDelay,
    BoxFit? fit,
    bool? enableHeroAnimation,
    String? heroTagPrefix,
    bool? enableGestureControl,
    bool? enableZoom,
    double? minScale,
    double? maxScale,
    bool? autoPlay,
    Duration? autoPlayInterval,
    bool? infiniteScroll,
    bool? enablePreload,
    int? preloadCount,
    double? height,
    double? width,
  }) {
    return ImageCarouselOptions(
      enableCache: enableCache ?? this.enableCache,
      enableErrorRetry: enableErrorRetry ?? this.enableErrorRetry,
      maxRetryCount: maxRetryCount ?? this.maxRetryCount,
      retryDelay: retryDelay ?? this.retryDelay,
      fit: fit ?? this.fit,
      enableHeroAnimation: enableHeroAnimation ?? this.enableHeroAnimation,
      heroTagPrefix: heroTagPrefix ?? this.heroTagPrefix,
      enableGestureControl: enableGestureControl ?? this.enableGestureControl,
      enableZoom: enableZoom ?? this.enableZoom,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      autoPlay: autoPlay ?? this.autoPlay,
      autoPlayInterval: autoPlayInterval ?? this.autoPlayInterval,
      infiniteScroll: infiniteScroll ?? this.infiniteScroll,
      enablePreload: enablePreload ?? this.enablePreload,
      preloadCount: preloadCount ?? this.preloadCount,
      height: height ?? this.height,
      width: width ?? this.width,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageCarouselOptions &&
        other.enableCache == enableCache &&
        other.enableErrorRetry == enableErrorRetry &&
        other.maxRetryCount == maxRetryCount &&
        other.retryDelay == retryDelay &&
        other.fit == fit &&
        other.enableHeroAnimation == enableHeroAnimation &&
        other.heroTagPrefix == heroTagPrefix &&
        other.enableGestureControl == enableGestureControl &&
        other.enableZoom == enableZoom &&
        other.minScale == minScale &&
        other.maxScale == maxScale &&
        other.autoPlay == autoPlay &&
        other.autoPlayInterval == autoPlayInterval &&
        other.infiniteScroll == infiniteScroll &&
        other.enablePreload == enablePreload &&
        other.preloadCount == preloadCount &&
        other.height == height &&
        other.width == width;
  }

  @override
  int get hashCode {
    return Object.hash(
      enableCache,
      enableErrorRetry,
      maxRetryCount,
      retryDelay,
      fit,
      enableHeroAnimation,
      heroTagPrefix,
      enableGestureControl,
      enableZoom,
      minScale,
      maxScale,
      autoPlay,
      autoPlayInterval,
      infiniteScroll,
      enablePreload,
      preloadCount,
      height,
      width,
    );
  }

  @override
  String toString() {
    return 'ImageCarouselOptions('
        'enableCache: $enableCache, '
        'enableErrorRetry: $enableErrorRetry, '
        'maxRetryCount: $maxRetryCount, '
        'retryDelay: $retryDelay, '
        'fit: $fit, '
        'enableHeroAnimation: $enableHeroAnimation, '
        'heroTagPrefix: $heroTagPrefix, '
        'enableGestureControl: $enableGestureControl, '
        'enableZoom: $enableZoom, '
        'minScale: $minScale, '
        'maxScale: $maxScale, '
        'autoPlay: $autoPlay, '
        'autoPlayInterval: $autoPlayInterval, '
        'infiniteScroll: $infiniteScroll, '
        'enablePreload: $enablePreload, '
        'preloadCount: $preloadCount'
        ')';
  }
}
