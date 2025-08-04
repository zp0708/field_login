import 'package:flutter/material.dart';
import 'image_carousel.dart';
import 'image_carousel_controller.dart';

class ImageViewerDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final ImageCarouselController? carouselController;
  final double? height;

  const ImageViewerDialog({
    super.key,
    required this.images,
    required this.initialIndex,
    this.carouselController,
    this.height,
  });

  /// 显示图片查看弹窗
  static void show(
    BuildContext context, {
    required List<String> images,
    required int initialIndex,
    ImageCarouselController? carouselController,
    double? height,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ImageViewerDialog(
        images: images,
        height: height,
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
    ImageCarouselController? carouselController,
    double? height,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: false,
      builder: (context) => ImageViewerDialog(
        images: images,
        initialIndex: initialIndex,
        carouselController: carouselController,
        height: height,
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
    if (widget.carouselController == null) {
      _viewerController = ImageCarouselController();
      _viewerController.setTotalCount(widget.images.length);
      _viewerController.setCurrentIndex(widget.initialIndex);
    } else {
      _viewerController = widget.carouselController!;
    }
  }

  @override
  void dispose() {
    if (widget.carouselController == null) {
      _viewerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.all(20),
        color: Colors.black.withOpacity(0.5), // 改为半透明
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图片轮播
            Flexible(
              child: ImageCarousel(
                images: widget.images,
                controller: _viewerController,
                autoPlay: false,
                enableZoom: true,
                height: widget.height,
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
          ],
        ),
      ),
    );
  }
}
