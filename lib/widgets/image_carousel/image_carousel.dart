import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'image_carousel_controller.dart';

/// 图片轮播器组件
class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final ImageCarouselController? controller;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? Function(String image, int index)? onImageTap;
  final Widget? Function(String image, int index)? imageBuilder;
  final bool infiniteScroll;

  // 新增功能
  final bool enableGestureControl; // 启用手势控制
  final bool enablePreload; // 启用预加载
  final int preloadCount; // 预加载数量
  final bool enableErrorRetry; // 启用错误重试
  final int maxRetryCount; // 最大重试次数
  final Duration retryDelay; // 重试延迟
  final Widget? placeholder; // 占位符
  final Widget? errorWidget; // 错误组件
  final bool enableZoom; // 启用缩放
  final double minScale; // 最小缩放比例
  final double maxScale; // 最大缩放比例
  // 缓存配置
  final bool enableCache; // 启用缓存
  final int? memCacheWidth; // 内存缓存宽度
  final int? memCacheHeight; // 内存缓存高度
  final int? maxWidthDiskCache; // 磁盘缓存最大宽度
  final int? maxHeightDiskCache; // 磁盘缓存最大高度
  final bool useOldImageOnUrlChange; // URL变化时是否使用旧图片
  // 覆盖层构建器
  final List<Widget> Function(ImageCarouselController controller)? overlaysBuilder; // 覆盖层构建器

  const ImageCarousel({
    super.key,
    required this.images,
    this.controller,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.onImageTap,
    this.imageBuilder,
    this.infiniteScroll = true,
    // 新增参数
    this.enableGestureControl = true,
    this.enablePreload = true,
    this.preloadCount = 2,
    this.enableErrorRetry = true,
    this.maxRetryCount = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.placeholder,
    this.errorWidget,
    this.enableZoom = false,
    this.minScale = 0.5,
    this.maxScale = 3.0,
    // 缓存配置参数
    this.enableCache = true,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.useOldImageOnUrlChange = true,
    // 覆盖层参数
    this.overlaysBuilder,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late ImageCarouselController _controller;
  late PageController _pageController;
  bool _isUpdatingFromController = false;
  Timer? _syncTimer;
  final Map<int, int> _retryCounts = {}; // 记录每个图片的重试次数
  final Map<int, bool> _imageLoadStates = {}; // 记录每个图片的加载状态

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ImageCarouselController();
    // 根据是否启用无限滚动来决定初始页面
    _pageController = PageController(
      initialPage: widget.infiniteScroll ? 5000 : 0,
    );
    _controller.setTotalCount(widget.images.length);

    // 监听控制器状态变化
    _controller.addListener(_onControllerChanged);

    // 确保初始状态同步
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.infiniteScroll) {
        final initialIndex = 5000 % widget.images.length;
        _controller.updateCurrentIndex(initialIndex);
      } else {
        _controller.updateCurrentIndex(0);
      }
    });

    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.startAutoPlay(interval: widget.autoPlayInterval);
      });
    }

    // 初始化图片加载状态
    for (int i = 0; i < widget.images.length; i++) {
      _imageLoadStates[i] = false;
      _retryCounts[i] = 0;
    }
  }

  @override
  void didUpdateWidget(ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 更新图片数量
    if (oldWidget.images.length != widget.images.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.setTotalCount(widget.images.length);
        // 重新初始化图片加载状态
        _imageLoadStates.clear();
        _retryCounts.clear();
        for (int i = 0; i < widget.images.length; i++) {
          _imageLoadStates[i] = false;
          _retryCounts[i] = 0;
        }
      });
    }

    // 处理自动播放状态变化
    if (widget.autoPlay != oldWidget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.autoPlay) {
          _controller.startAutoPlay(interval: widget.autoPlayInterval);
        } else {
          _controller.stopAutoPlay();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _syncTimer?.cancel();
    // 只有在我们创建的控制器时才销毁它
    if (widget.controller == null) {
      _controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    // 取消之前的同步定时器
    _syncTimer?.cancel();

    // 立即同步，避免延迟导致的状态不一致
    if (_pageController.hasClients && !_isUpdatingFromController) {
      if (widget.infiniteScroll) {
        final currentPage = _pageController.page?.round() ?? 0;
        final actualIndex = currentPage % widget.images.length;

        if (actualIndex != _controller.currentIndex) {
          _isUpdatingFromController = true;

          // 计算最短路径的目标页面索引
          final currentActualIndex = actualIndex;
          final targetActualIndex = _controller.currentIndex;

          // 计算最短的跳跃距离
          int shortestDistance = targetActualIndex - currentActualIndex;
          if (shortestDistance.abs() > widget.images.length / 2) {
            if (shortestDistance > 0) {
              shortestDistance -= widget.images.length;
            } else {
              shortestDistance += widget.images.length;
            }
          }

          final targetPage = currentPage + shortestDistance;

          // 使用更快的动画，减少延迟
          _pageController
              .animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          )
              .then((_) {
            _isUpdatingFromController = false;
          });
        }
      } else {
        // 普通模式
        if (_pageController.page?.round() != _controller.currentIndex) {
          _isUpdatingFromController = true;
          _pageController
              .animateToPage(
            _controller.currentIndex,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          )
              .then((_) {
            _isUpdatingFromController = false;
          });
        }
      }
    }
  }

  Widget _buildInfinitePageView() {
    if (widget.images.length <= 1) {
      return _buildSinglePageView();
    }

    if (widget.infiniteScroll) {
      // 无限滚动模式
      return PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          // 计算实际的图片索引
          final actualIndex = index % widget.images.length;

          if (!_isUpdatingFromController) {
            // 立即更新控制器状态，不使用延迟
            _controller.updateCurrentIndex(actualIndex);
          }

          // 预加载逻辑
          if (widget.enablePreload) {
            _preloadImages(actualIndex);
          }
        },
        itemCount: 10000, // 使用一个很大的数字来实现无限滚动
        itemBuilder: (context, index) {
          // 计算实际的图片索引
          final actualIndex = index % widget.images.length;
          return _buildPageItem(widget.images[actualIndex], actualIndex);
        },
      );
    } else {
      // 普通模式
      return PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          if (!_isUpdatingFromController) {
            // 立即更新控制器状态，不使用延迟
            _controller.updateCurrentIndex(index);
          }

          // 预加载逻辑
          if (widget.enablePreload) {
            _preloadImages(index);
          }
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return _buildPageItem(widget.images[index], index);
        },
      );
    }
  }

  void _preloadImages(int currentIndex) {
    // 预加载当前图片前后的图片
    for (int i = 1; i <= widget.preloadCount; i++) {
      final nextIndex = (currentIndex + i) % widget.images.length;
      final prevIndex = (currentIndex - i + widget.images.length) % widget.images.length;

      // 预加载下一张图片
      _preloadImage(nextIndex);
      // 预加载上一张图片
      _preloadImage(prevIndex);
    }
  }

  void _preloadImage(int index) {
    if (index >= 0 && index < widget.images.length) {
      if (widget.enableCache) {
        // 使用 CachedNetworkImageProvider 进行预加载
        final imageProvider = CachedNetworkImageProvider(
          widget.images[index],
          cacheKey: 'carousel_$index',
        );
        precacheImage(imageProvider, context);
      } else {
        // 使用 NetworkImage 进行预加载
        precacheImage(NetworkImage(widget.images[index]), context);
      }
    }
  }

  Widget _buildSinglePageView() {
    return _buildPageItem(widget.images[0], 0);
  }

  Widget _buildPageItem(String image, int index) {
    // 使用自定义图片构建器或默认构建器
    if (widget.imageBuilder != null) {
      final customWidget = widget.imageBuilder!(image, index);
      if (customWidget != null) {
        return _buildGestureWrapper(customWidget, image, index);
      }
    }

    // 默认图片构建器
    return _buildGestureWrapper(_buildDefaultImage(image, index), image, index);
  }

  Widget _buildGestureWrapper(Widget child, String image, int index) {
    Widget wrappedChild = child;

    // 添加缩放功能
    if (widget.enableZoom) {
      wrappedChild = InteractiveViewer(
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        constrained: true, // 添加约束
        child: wrappedChild,
      );
    }

    // 添加手势控制
    if (widget.enableGestureControl) {
      wrappedChild = GestureDetector(
        onTap: () => widget.onImageTap?.call(image, index),
        onDoubleTap: widget.enableZoom
            ? () {
                // 双击缩放逻辑可以在这里添加
              }
            : null,
        child: wrappedChild,
      );
    } else {
      wrappedChild = GestureDetector(
        onTap: () => widget.onImageTap?.call(image, index),
        child: wrappedChild,
      );
    }

    return wrappedChild;
  }

  Widget _buildDefaultImage(String image, int index) {
    if (widget.enableCache) {
      return CachedNetworkImage(
        imageUrl: image,
        fit: widget.fit,
        placeholder: (context, url) {
          return _buildLoadingWidget(null);
        },
        errorWidget: (context, url, error) {
          return _buildErrorWidget(index, error);
        },
        imageBuilder: (context, imageProvider) {
          _imageLoadStates[index] = true;
          return Image(image: imageProvider, fit: widget.fit);
        },
        // 缓存配置
        memCacheWidth: widget.memCacheWidth ?? 800, // 内存缓存宽度
        memCacheHeight: widget.memCacheHeight ?? 600, // 内存缓存高度
        maxWidthDiskCache: widget.maxWidthDiskCache ?? 1024, // 磁盘缓存最大宽度
        maxHeightDiskCache: widget.maxHeightDiskCache ?? 768, // 磁盘缓存最大高度
        // 缓存策略
        cacheKey: 'carousel_$index', // 自定义缓存键
        useOldImageOnUrlChange: widget.useOldImageOnUrlChange, // URL变化时使用旧图片
      );
    } else {
      // 不使用缓存，回退到原始 Image.network
      return Image.network(
        image,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget(index, error);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            _imageLoadStates[index] = true;
            return child;
          }
          return _buildLoadingWidget(loadingProgress);
        },
      );
    }
  }

  Widget _buildErrorWidget(int index, Object error) {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // 添加这个约束
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              color: Colors.grey,
              size: 50,
            ),
            const SizedBox(height: 8),
            const Text(
              '图片加载失败',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            if (widget.enableErrorRetry && _retryCounts[index]! < widget.maxRetryCount)
              TextButton(
                onPressed: () => _retryLoadImage(index),
                child: const Text('重试'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget([ImageChunkEvent? loadingProgress]) {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // 添加这个约束
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: loadingProgress?.expectedTotalBytes != null
                  ? loadingProgress!.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              loadingProgress != null
                  ? '加载中... ${((loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)) * 100).toStringAsFixed(0)}%'
                  : '加载中...',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _retryLoadImage(int index) {
    if (_retryCounts[index]! < widget.maxRetryCount) {
      _retryCounts[index] = _retryCounts[index]! + 1;
      setState(() {
        _imageLoadStates[index] = false;
      });

      // 延迟重试
      Future.delayed(widget.retryDelay, () {
        if (mounted) {
          setState(() {
            // 触发重新加载
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: widget.height, // 提供默认高度
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
      ),
      clipBehavior: widget.borderRadius != null ? Clip.antiAlias : Clip.none,
      child: Stack(
        children: [
          // 轮播图片区域
          Positioned.fill(
            child: _buildInfinitePageView(),
          ),

          // 覆盖层
          if (widget.overlaysBuilder != null) ...widget.overlaysBuilder!(_controller),
        ],
      ),
    );
  }
}
