import 'package:flutter/material.dart';
import 'image_carousel.dart';
import 'image_carousel_controller.dart';
import 'carousel_indicator.dart';

class ImageViewerDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final ImageCarouselController? carouselController;

  const ImageViewerDialog({
    super.key,
    required this.images,
    required this.initialIndex,
    this.carouselController,
  });

  /// 显示图片查看弹窗
  static void show(
    BuildContext context, {
    required List<String> images,
    required int initialIndex,
    ImageCarouselController? carouselController,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ImageViewerDialog(
        images: images,
        initialIndex: initialIndex,
        carouselController: carouselController,
      ),
    );
  }

  /// 从轮播图控制器创建图片查看弹窗
  static void showFromCarousel(
    BuildContext context, {
    required List<String> images,
    required int initialIndex,
    required ImageCarouselController carouselController,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ImageViewerDialog(
        images: images,
        initialIndex: initialIndex,
        carouselController: carouselController,
      ),
    );
  }

  @override
  State<ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<ImageViewerDialog> {
  late ImageCarouselController _viewerController;

  @override
  void initState() {
    super.initState();
    _viewerController = ImageCarouselController();
    _viewerController.setTotalCount(widget.images.length);
    _viewerController.setCurrentIndex(widget.initialIndex);
    
    // 监听轮播器控制器变化
    if (widget.carouselController != null) {
      widget.carouselController!.addListener(_onCarouselControllerChanged);
    }
    
    // 监听查看器控制器变化
    _viewerController.addListener(_onViewerControllerChanged);
  }

  @override
  void dispose() {
    _viewerController.removeListener(_onViewerControllerChanged);
    if (widget.carouselController != null) {
      widget.carouselController!.removeListener(_onCarouselControllerChanged);
    }
    _viewerController.dispose();
    super.dispose();
  }

  void _onCarouselControllerChanged() {
    // 轮播器控制器变化时，同步到查看器
    if (_viewerController.currentIndex != widget.carouselController!.currentIndex) {
      _viewerController.setCurrentIndex(widget.carouselController!.currentIndex);
    }
  }

  void _onViewerControllerChanged() {
    // 查看器控制器变化时，同步到轮播器
    if (widget.carouselController != null && 
        _viewerController.currentIndex != widget.carouselController!.currentIndex) {
      widget.carouselController!.setCurrentIndex(_viewerController.currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.8),
        child: Column(
          children: [
            // 轮播图组件
            Expanded(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: ImageCarousel(
                  images: widget.images,
                  controller: _viewerController,
                  autoPlay: false,
                  showIndicator: true,
                  indicatorType: CarouselIndicatorType.dots,
                  indicatorActiveColor: Colors.white,
                  indicatorInactiveColor: Colors.white.withOpacity(0.5),
                  imageBuilder: (image, index) {
                    return _buildImageItem(image, index);
                  },
                ),
              ),
            ),
            
            // 顶部工具栏
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 图片计数器
                  ListenableBuilder(
                    listenable: _viewerController,
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
                          '${_viewerController.currentIndex + 1} / ${widget.images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // 关闭按钮
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(String imageUrl, int index) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 50,
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[800],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 