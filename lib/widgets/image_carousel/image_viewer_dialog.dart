import 'package:flutter/material.dart';
import 'image_carousel.dart';
import 'image_carousel_controller.dart';

class ImageViewerDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final ImageCarouselController? controller;
  final double? height;
  final bool enableHeroAnimation;
  final String? heroTagPrefix;

  const ImageViewerDialog({
    super.key,
    required this.images,
    required this.initialIndex,
    this.controller,
    this.height,
    this.enableHeroAnimation = false,
    this.heroTagPrefix,
  });

  /// 显示图片查看弹窗
  static void show(
    BuildContext context, {
    required List<String> images,
    required int initialIndex,
    ImageCarouselController? controller,
    double? height,
    bool enableHeroAnimation = false,
    String? heroTagPrefix,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.8),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ImageViewerDialog(
            images: images,
            height: height,
            initialIndex: initialIndex,
            controller: controller,
            enableHeroAnimation: enableHeroAnimation,
            heroTagPrefix: heroTagPrefix,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
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
    print('ImageViewerDialog initState - 初始索引: ${widget.initialIndex}');
    if (widget.controller == null) {
      _viewerController = ImageCarouselController();
      _viewerController.setTotalCount(widget.images.length);
      _viewerController.setCurrentIndex(widget.initialIndex);
    } else {
      _viewerController = widget.controller!;
      print('使用共享控制器 - 控制器当前索引: ${_viewerController.currentIndex}');
      // 确保共享控制器也设置正确的初始索引
      _viewerController.setCurrentIndex(widget.initialIndex);
      print('设置后控制器索引: ${_viewerController.currentIndex}');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 确保在依赖变化时也设置正确的索引
    if (widget.controller != null) {
      _viewerController.setCurrentIndex(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _viewerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // 图片轮播
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ImageCarousel(
                  images: widget.images,
                  controller: _viewerController,
                  autoPlay: false,
                  enableZoom: true,
                  height: widget.height,
                  borderRadius: BorderRadius.circular(9.0),
                  enableHeroAnimation: widget.enableHeroAnimation,
                  heroTagPrefix: widget.heroTagPrefix,
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
