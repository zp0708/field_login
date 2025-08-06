import 'package:flutter/material.dart';
import 'image_carousel.dart';
import 'image_carousel_controller.dart';

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
        padding: EdgeInsets.all(20),
        color: Colors.black.withOpacity(0.5), // 改为半透明
        child: Column(children: [
          // 图片轮播
          Flexible(
            child: ImageCarousel(
              images: widget.images,
              controller: _viewerController,
              autoPlay: false,
              enableZoom: true,
              borderRadius: BorderRadius.circular(9.0),
              showIndicator: true, // 隐藏默认指示器
            ),
          ),
          SizedBox(height: 20),
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
          )
        ]),
      ),
    );
  }
}
