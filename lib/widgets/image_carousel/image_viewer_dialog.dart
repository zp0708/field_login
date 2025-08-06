import 'package:flutter/material.dart';
import 'image_carousel.dart';
import 'image_carousel_controller.dart';
import 'models/carousel_options.dart';

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
        barrierColor: Color.fromRGBO(0, 0, 0, 0.8),
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
          // 如果启用Hero动画，则不使用额外的过渡动画
          if (enableHeroAnimation) {
            return child;
          }
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
    if (widget.controller == null) {
      _viewerController = ImageCarouselController();
      _viewerController.setTotalCount(widget.images.length);
      _viewerController.setCurrentIndex(widget.initialIndex);
    } else {
      _viewerController = widget.controller!;
      // 确保共享控制器也设置正确的初始索引
      _viewerController.setCurrentIndex(widget.initialIndex);
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
  void didUpdateWidget(ImageViewerDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 确保在widget更新时也设置正确的索引
    if (widget.initialIndex != oldWidget.initialIndex) {
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
            SizedBox(height: 20),
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
                  enableHeroAnimation: widget.enableHeroAnimation,
                  heroTagPrefix: widget.heroTagPrefix,
                  borderRadius: BorderRadius.circular(9.0),
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
                      color: Color.fromRGBO(0, 0, 0, 0.5),
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
