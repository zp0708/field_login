import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../managers/error_manager.dart';
import '../models/carousel_options.dart';

/// 图片轮播图片构建器
///
/// 负责处理图片的加载和显示逻辑，支持缓存、Hero动画等功能。
/// 提供统一的图片构建接口，处理加载状态和错误情况。
class ImageCarouselImageBuilder extends StatelessWidget {
  /// 配置选项
  final ImageCarouselOptions options;

  /// 错误管理器
  final ImageCarouselErrorManager errorManager;

  /// 图片URL
  final String image;

  /// 图片索引
  final int index;

  /// 占位符组件
  final Widget? placeholder;

  /// 错误组件
  final Widget? errorWidget;

  /// 创建图片构建器实例
  ///
  /// [options] 配置选项
  /// [errorManager] 错误管理器
  /// [image] 图片URL
  /// [index] 图片索引
  /// [placeholder] 占位符组件
  /// [errorWidget] 错误组件
  const ImageCarouselImageBuilder({
    super.key,
    required this.options,
    required this.errorManager,
    required this.image,
    required this.index,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget = _buildImageWidget();

    if (options.enableHeroAnimation) {
      return _buildHeroWidget(imageWidget);
    }

    return imageWidget;
  }

  /// 构建Hero动画组件
  ///
  /// [child] 子组件
  /// 返回Hero动画组件
  Widget _buildHeroWidget(Widget child) {
    final String heroTag = _generateHeroTag();
    return Hero(
      tag: heroTag,
      child: child,
    );
  }

  /// 生成Hero标签
  ///
  /// 返回唯一的Hero标签
  String _generateHeroTag() {
    final String prefix = options.heroTagPrefix ?? 'image_carousel';
    return '$prefix-$index';
  }

  /// 构建图片组件
  ///
  /// 返回图片组件
  Widget _buildImageWidget() {
    if (options.enableCache) {
      return _buildCachedImage();
    } else {
      return _buildNetworkImage();
    }
  }

  /// 构建缓存图片
  ///
  /// 返回缓存图片组件
  Widget _buildCachedImage() {
    return CachedNetworkImage(
      imageUrl: image,
      fit: options.fit,
      placeholder: (BuildContext context, String url) {
        return placeholder ?? _buildDefaultPlaceholder();
      },
      errorWidget: (BuildContext context, String url, dynamic error) {
        return _buildErrorWidget(error);
      },
      errorListener: (dynamic error) {
        _handleImageError(error);
      },
    );
  }

  /// 构建网络图片
  ///
  /// 返回网络图片组件
  Widget _buildNetworkImage() {
    return Image.network(
      image,
      fit: options.fit,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return placeholder ?? _buildDefaultPlaceholder();
      },
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        return _buildErrorWidget(error);
      },
    );
  }

  /// 构建默认占位符
  ///
  /// 返回默认占位符组件
  Widget _buildDefaultPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// 构建错误组件
  ///
  /// [error] 错误信息
  /// 返回错误组件
  Widget _buildErrorWidget(dynamic error) {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              color: Colors.grey[600],
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              '图片加载失败',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (options.enableErrorRetry) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _retryImageLoad(),
                child: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 处理图片错误
  ///
  /// [error] 错误信息
  void _handleImageError(dynamic error) {
    errorManager.setImageLoadState(index, false);
  }

  /// 重试图片加载
  void _retryImageLoad() {
    if (options.enableErrorRetry) {
      errorManager.retryLoadImage(index);
    }
  }
}
