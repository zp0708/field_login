import 'package:flutter/material.dart';

/// 图片轮播错误管理器
///
/// 负责处理图片加载错误、重试逻辑和状态管理。
/// 提供统一的错误处理接口，支持重试机制和状态跟踪。
class ImageCarouselErrorManager {
  /// 是否启用错误重试
  final bool enableErrorRetry;

  /// 最大重试次数
  final int maxRetryCount;

  /// 重试延迟时间
  final Duration retryDelay;

  /// 状态变化回调
  final VoidCallback onStateChanged;

  /// 重试次数映射表
  final Map<int, int> _retryCounts = <int, int>{};

  /// 图片加载状态映射表
  final Map<int, bool> _imageLoadStates = <int, bool>{};

  /// 创建错误管理器实例
  ///
  /// [enableErrorRetry] 是否启用错误重试
  /// [maxRetryCount] 最大重试次数
  /// [retryDelay] 重试延迟时间
  /// [onStateChanged] 状态变化回调
  ImageCarouselErrorManager({
    required this.enableErrorRetry,
    required this.maxRetryCount,
    required this.retryDelay,
    required this.onStateChanged,
  });

  /// 获取指定索引的重试次数
  ///
  /// [index] 图片索引
  /// 返回重试次数，如果未记录则返回 0
  int getRetryCount(int index) => _retryCounts[index] ?? 0;

  /// 获取指定索引的图片加载状态
  ///
  /// [index] 图片索引
  /// 返回加载状态，如果未记录则返回 false
  bool getImageLoadState(int index) => _imageLoadStates[index] ?? false;

  /// 设置指定索引的图片加载状态
  ///
  /// [index] 图片索引
  /// [state] 加载状态
  void setImageLoadState(int index, bool state) {
    _imageLoadStates[index] = state;
    onStateChanged();
  }

  /// 重试加载指定索引的图片
  ///
  /// [index] 图片索引
  /// 如果重试次数未超过限制，则触发重试逻辑
  void retryLoadImage(int index) {
    if (!canRetry(index)) return;

    _retryCounts[index] = getRetryCount(index) + 1;
    setImageLoadState(index, false);

    // 延迟重试
    Future<void>.delayed(retryDelay, () {
      onStateChanged();
    });
  }

  /// 初始化图片状态
  ///
  /// [imageCount] 图片总数
  /// 为每个图片初始化加载状态和重试次数
  void initializeImageStates(int imageCount) {
    for (int i = 0; i < imageCount; i++) {
      _imageLoadStates[i] = false;
      _retryCounts[i] = 0;
    }
  }

  /// 清除所有图片状态
  ///
  /// 清空重试次数和加载状态映射表
  void clearImageStates() {
    _imageLoadStates.clear();
    _retryCounts.clear();
  }

  /// 检查指定索引的图片是否可以重试
  ///
  /// [index] 图片索引
  /// 返回是否可以重试
  bool canRetry(int index) {
    return enableErrorRetry && getRetryCount(index) < maxRetryCount;
  }

  /// 获取指定索引的剩余重试次数
  ///
  /// [index] 图片索引
  /// 返回剩余重试次数
  int getRemainingRetries(int index) {
    return maxRetryCount - getRetryCount(index);
  }
}
