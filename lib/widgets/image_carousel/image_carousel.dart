import 'dart:async';
import 'package:flutter/material.dart';
import 'image_carousel_controller.dart';
import 'carousel_indicator.dart';

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
  final bool showIndicator;
  final CarouselIndicatorType indicatorType;
  final Color? indicatorActiveColor;
  final Color? indicatorInactiveColor;
  final double? indicatorSize;
  final EdgeInsetsGeometry? indicatorPadding;
  final VoidCallback? onImageTap;
  final Widget? Function(String image, int index)? imageBuilder;
  final bool infiniteScroll;
  final Function(int index)? onImageViewer;
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
    this.showIndicator = true,
    this.indicatorType = CarouselIndicatorType.dots,
    this.indicatorActiveColor,
    this.indicatorInactiveColor,
    this.indicatorSize,
    this.indicatorPadding,
    this.onImageTap,
    this.imageBuilder,
    this.infiniteScroll = true,
    this.onImageViewer,
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

    // 延迟同步，避免频繁更新
    _syncTimer = Timer(const Duration(milliseconds: 100), () {
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

            // 使用更平滑的动画
            _pageController
                .animateToPage(
              targetPage,
              duration: const Duration(milliseconds: 10),
              curve: Curves.easeInOut,
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
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
                .then((_) {
              _isUpdatingFromController = false;
            });
          }
        }
      }
    });
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
          _controller.updateCurrentIndex(index);

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
    // 这里可以添加预加载逻辑，比如使用 precacheImage
    if (index >= 0 && index < widget.images.length) {
      precacheImage(NetworkImage(widget.images[index]), context);
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
        return _buildGestureWrapper(customWidget, index);
      }
    }

    // 默认图片构建器
    return _buildGestureWrapper(_buildDefaultImage(image, index), index);
  }

  Widget _buildGestureWrapper(Widget child, int index) {
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
        onTap: widget.onImageViewer != null ? () => widget.onImageViewer!(index) : widget.onImageTap,
        onDoubleTap: widget.enableZoom
            ? () {
                // 双击缩放逻辑可以在这里添加
              }
            : null,
        child: wrappedChild,
      );
    } else {
      wrappedChild = GestureDetector(
        onTap: widget.onImageViewer != null ? () => widget.onImageViewer!(index) : widget.onImageTap,
        child: wrappedChild,
      );
    }

    return wrappedChild;
  }

  Widget _buildDefaultImage(String image, int index) {
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

  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
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
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              '加载中... ${((loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)) * 100).toStringAsFixed(0)}%',
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

          // 指示器
          if (widget.showIndicator && widget.images.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CarouselIndicator(
                      currentIndex: _controller.currentIndex,
                      totalCount: _controller.totalCount,
                      type: widget.indicatorType,
                      activeColor: widget.indicatorActiveColor,
                      inactiveColor: widget.indicatorInactiveColor,
                      size: widget.indicatorSize,
                      padding: widget.indicatorPadding,
                      onIndicatorTap: () {
                        // 可以在这里添加点击指示器的逻辑
                      },
                    );
                  },
                ),
              ),
            ),

          if (widget.showIndicator && widget.images.length > 1)
            Positioned(
              bottom: 10,
              right: 10,
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_controller.currentIndex + 1} / ${widget.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
