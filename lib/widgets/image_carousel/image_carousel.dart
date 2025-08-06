import 'dart:async';
import 'package:flutter/material.dart';
import 'image_carousel_controller.dart';
import 'managers/preload_manager.dart';
import 'managers/error_manager.dart';
import 'models/carousel_options.dart';
import 'widgets/page_view_builder.dart';

/// 图片轮播器组件
///
/// 一个功能丰富的图片轮播组件，支持自动播放、手势控制、预加载、
/// 错误重试、Hero动画等功能。提供高度可定制的配置选项。
class ImageCarousel extends StatefulWidget {
  /// 图片列表
  final List<String> images;

  /// 控制器
  final ImageCarouselController? controller;

  /// 配置选项
  final ImageCarouselOptions options;

  // UI相关配置项
  /// 占位符组件
  final Widget? placeholder;

  /// 错误组件
  final Widget? errorWidget;

  /// 图片点击回调
  final void Function(ImageCarouselController controller, String image, int index)? onImageTap;

  /// 自定义图片构建器
  final Widget? Function(String image, int index)? imageBuilder;

  /// 圆角
  final BorderRadius? borderRadius;

  /// 覆盖层构建器
  final List<Widget> Function(ImageCarouselController controller)? overlaysBuilder;

  /// 创建图片轮播器实例
  ///
  /// [images] 图片列表
  /// [controller] 控制器
  /// [autoPlay] 是否自动播放
  /// [autoPlayInterval] 自动播放间隔
  /// [height] 高度
  /// [width] 宽度
  /// [fit] 图片适配方式
  /// [borderRadius] 圆角
  /// [enableCache] 是否启用缓存
  /// [onImageTap] 图片点击回调
  /// [imageBuilder] 自定义图片构建器
  /// [infiniteScroll] 是否启用无限滚动
  /// [enableGestureControl] 是否启用手势控制
  /// [enablePreload] 是否启用预加载
  /// [preloadCount] 预加载数量
  /// [enableErrorRetry] 是否启用错误重试
  /// [maxRetryCount] 最大重试次数
  /// [retryDelay] 重试延迟
  /// [placeholder] 占位符组件
  /// [errorWidget] 错误组件
  /// [enableZoom] 是否启用缩放
  /// [minScale] 最小缩放比例
  /// [maxScale] 最大缩放比例
  /// [enableHeroAnimation] 是否启用Hero动画
  /// [heroTagPrefix] Hero标签前缀
  /// [overlaysBuilder] 覆盖层构建器
  ImageCarousel({
    super.key,
    required this.images,
    this.controller,
    this.onImageTap,
    this.imageBuilder,
    this.overlaysBuilder,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    bool autoPlay = false,
    Duration autoPlayInterval = const Duration(seconds: 3),
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
    bool enableCache = true,
    bool infiniteScroll = true,
    bool enableGestureControl = true,
    bool enablePreload = true,
    int preloadCount = 2,
    bool enableErrorRetry = true,
    int maxRetryCount = 3,
    Duration retryDelay = const Duration(seconds: 2),
    bool enableZoom = false,
    double minScale = 0.5,
    double maxScale = 3.0,
    bool enableHeroAnimation = false,
    String? heroTagPrefix,
    ImageCarouselOptions? options,
  }) : options = options ??
            ImageCarouselOptions(
              autoPlay: autoPlay,
              autoPlayInterval: autoPlayInterval,
              height: height,
              width: width,
              fit: fit,
              enableCache: enableCache,
              infiniteScroll: infiniteScroll,
              enableGestureControl: enableGestureControl,
              enablePreload: enablePreload,
              preloadCount: preloadCount,
              enableErrorRetry: enableErrorRetry,
              maxRetryCount: maxRetryCount,
              retryDelay: retryDelay,
              enableZoom: enableZoom,
              minScale: minScale,
              maxScale: maxScale,
              enableHeroAnimation: enableHeroAnimation,
              heroTagPrefix: heroTagPrefix,
            );

  /// 创建图片轮播器实例（使用命名参数）
  ///
  /// [images] 图片列表
  /// [options] 配置
  /// [controller] 控制器
  /// [borderRadius] 圆角
  /// [onImageTap] 图片点击回调
  /// [imageBuilder] 自定义图片构建器
  /// [placeholder] 占位符组件
  /// [errorWidget] 错误组件
  /// [overlaysBuilder] 覆盖层构建器
  const ImageCarousel.withOptions({
    super.key,
    required this.images,
    required this.options,
    this.controller,
    this.onImageTap,
    this.imageBuilder,
    this.overlaysBuilder,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  /// 控制器
  late ImageCarouselController _controller;

  /// 页面控制器
  late PageController _pageController;

  /// 是否正在从控制器更新
  bool _isUpdatingFromController = false;

  /// 同步定时器
  Timer? _syncTimer;

  // 管理器实例
  late ImageCarouselPreloadManager _preloadManager;
  late ImageCarouselErrorManager _errorManager;

  @override
  void initState() {
    super.initState();
    _initializeManagers();
    _initializeController();
    _initializePageController();
    _initializeAutoPlay();
    _errorManager.initializeImageStates(widget.images.length);
  }

  /// 初始化管理器
  void _initializeManagers() {
    _preloadManager = ImageCarouselPreloadManager(
      enablePreload: widget.options.enablePreload,
      preloadCount: widget.options.preloadCount,
      enableCache: widget.options.enableCache,
      images: widget.images,
    );

    _errorManager = ImageCarouselErrorManager(
      enableErrorRetry: widget.options.enableErrorRetry,
      maxRetryCount: widget.options.maxRetryCount,
      retryDelay: widget.options.retryDelay,
      onStateChanged: () => setState(() {}),
    );
  }

  /// 初始化控制器
  void _initializeController() {
    _controller = widget.controller ?? ImageCarouselController();
    _controller.setTotalCount(widget.images.length);
    _controller.addListener(_onControllerChanged);
  }

  /// 初始化页面控制器
  void _initializePageController() {
    final int initialPage = _calculateInitialPage();
    _pageController = PageController(initialPage: initialPage);

    // 确保初始状态同步
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncInitialIndex();
    });
  }

  /// 计算初始页面
  int _calculateInitialPage() {
    if (widget.controller != null) {
      final int controllerIndex = widget.controller!.currentIndex;
      return widget.options.infiniteScroll ? controllerIndex : controllerIndex;
    }
    // 对于无限滚动，直接使用0作为初始页面
    // 因为 itemCount 为 null，PageView 可以无限滚动
    return 0;
  }

  /// 同步初始索引
  void _syncInitialIndex() {
    final int initialIndex = widget.controller?.currentIndex ?? 0;
    _controller.updateCurrentIndex(initialIndex);
  }

  /// 初始化自动播放
  void _initializeAutoPlay() {
    if (widget.options.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.startAutoPlay(interval: widget.options.autoPlayInterval);
      });
    }
  }

  @override
  void didUpdateWidget(ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleWidgetUpdate(oldWidget);
  }

  /// 处理组件更新
  void _handleWidgetUpdate(ImageCarousel oldWidget) {
    _handleImagesUpdate(oldWidget);
    _handleControllerUpdate(oldWidget);
    _handleAutoPlayUpdate(oldWidget);
  }

  /// 处理图片列表更新
  void _handleImagesUpdate(ImageCarousel oldWidget) {
    if (oldWidget.images.length != widget.images.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.setTotalCount(widget.images.length);
        _errorManager.clearImageStates();
        _errorManager.initializeImageStates(widget.images.length);
      });
    }
  }

  /// 处理控制器更新
  void _handleControllerUpdate(ImageCarousel oldWidget) {
    if (oldWidget.controller != widget.controller) {
      if (widget.controller != null) {
        final int currentIndex = widget.controller!.currentIndex;

        if (_pageController.hasClients) {
          _pageController.jumpToPage(currentIndex);
        }
      }
    }
  }

  /// 处理自动播放更新
  void _handleAutoPlayUpdate(ImageCarousel oldWidget) {
    if (widget.options.autoPlay != oldWidget.options.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.options.autoPlay) {
          _controller.startAutoPlay(interval: widget.options.autoPlayInterval);
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
    if (widget.controller == null) {
      _controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  /// 控制器变化回调
  void _onControllerChanged() {
    _syncTimer?.cancel();

    if (!_pageController.hasClients || _isUpdatingFromController) return;

    if (widget.options.infiniteScroll) {
      _handleInfiniteScrollUpdate();
    } else {
      _handleNormalScrollUpdate();
    }
  }

  /// 处理无限滚动更新
  void _handleInfiniteScrollUpdate() {
    final int currentPage = _pageController.page?.round() ?? 0;
    final int actualIndex = currentPage % widget.images.length;

    if (actualIndex != _controller.currentIndex) {
      _isUpdatingFromController = true;

      // 计算最短距离的目标页面
      final int targetPage = _calculateTargetPage(currentPage, actualIndex);

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
  }

  /// 处理普通滚动更新
  void _handleNormalScrollUpdate() {
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

  /// 计算目标页面
  int _calculateTargetPage(int currentPage, int actualIndex) {
    final int targetActualIndex = _controller.currentIndex;

    // 如果目标索引和当前实际索引相同，不需要跳转
    if (targetActualIndex == actualIndex) {
      return currentPage;
    }

    // 计算最短距离
    int shortestDistance = targetActualIndex - actualIndex;

    // 处理循环情况，选择最短路径
    if (shortestDistance.abs() > widget.images.length / 2) {
      if (shortestDistance > 0) {
        shortestDistance -= widget.images.length;
      } else {
        shortestDistance += widget.images.length;
      }
    }

    return currentPage + shortestDistance;
  }

  /// 构建页面视图
  Widget _buildPageView() {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    if (widget.images.length <= 1) {
      return SinglePageBuilder(
        image: widget.images[0],
        options: widget.options,
        placeholder: widget.placeholder,
        errorWidget: widget.errorWidget,
        onImageTap: (image, index) => widget.onImageTap?.call(_controller, image, index),
        imageBuilder: widget.imageBuilder,
        errorManager: _errorManager,
      );
    }

    if (widget.options.infiniteScroll) {
      return InfinitePageViewBuilder(
        controller: _pageController,
        images: widget.images,
        onPageChanged: _handlePageChanged,
        options: widget.options,
        placeholder: widget.placeholder,
        errorWidget: widget.errorWidget,
        onImageTap: (image, index) => widget.onImageTap?.call(_controller, image, index),
        imageBuilder: widget.imageBuilder,
        errorManager: _errorManager,
      );
    } else {
      return NormalPageViewBuilder(
        controller: _pageController,
        images: widget.images,
        onPageChanged: _handlePageChanged,
        options: widget.options,
        placeholder: widget.placeholder,
        errorWidget: widget.errorWidget,
        onImageTap: (image, index) => widget.onImageTap?.call(_controller, image, index),
        imageBuilder: widget.imageBuilder,
        errorManager: _errorManager,
      );
    }
  }

  /// 处理页面变化
  void _handlePageChanged(int index) {
    if (!_isUpdatingFromController) {
      // 对于无限滚动，需要计算实际的图片索引
      final int actualIndex = widget.options.infiniteScroll ? index % widget.images.length : index;
      _controller.updateCurrentIndex(actualIndex);
    }

    if (widget.options.enablePreload) {
      final int actualIndex = widget.options.infiniteScroll ? index % widget.images.length : index;
      _preloadManager.preloadImages(actualIndex, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: widget.options.height,
      width: widget.options.width,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
      ),
      clipBehavior: widget.borderRadius != null ? Clip.antiAlias : Clip.none,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: _buildPageView(),
          ),
          if (widget.overlaysBuilder != null) ...widget.overlaysBuilder!(_controller),
        ],
      ),
    );
  }
}
