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
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late ImageCarouselController _controller;
  late PageController _pageController;
  bool _isUpdatingFromController = false;
  Timer? _syncTimer;

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
  }

  @override
  void didUpdateWidget(ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 更新图片数量
    if (oldWidget.images.length != widget.images.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.setTotalCount(widget.images.length);
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
            _pageController.animateToPage(
              targetPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ).then((_) {
              _isUpdatingFromController = false;
            });
          }
        } else {
          // 普通模式
          if (_pageController.page?.round() != _controller.currentIndex) {
            _isUpdatingFromController = true;
            _pageController.animateToPage(
              _controller.currentIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ).then((_) {
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
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return _buildPageItem(widget.images[index], index);
        },
      );
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
        return GestureDetector(
          onTap: widget.onImageTap,
          child: customWidget,
        );
      }
    }
    
    // 默认图片构建器
    return GestureDetector(
      onTap: widget.onImageTap,
      child: Image.network(
        image,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.error,
              color: Colors.grey,
              size: 50,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // 轮播图片区域
        Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
          ),
          clipBehavior: widget.borderRadius != null ? Clip.antiAlias : Clip.none,
          child: _buildInfinitePageView(),
        ),
        
        // 指示器
        if (widget.showIndicator && widget.images.length > 1)
          AnimatedBuilder(
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
      ],
    );
  }
} 