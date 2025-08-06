import 'package:flutter/material.dart';
import '../widgets/image_carousel/image_carousel.dart';
import '../widgets/image_carousel/image_carousel_controller.dart';
import '../widgets/image_carousel/image_viewer_dialog.dart';
import '../widgets/image_carousel/models/carousel_options.dart';

class CarouselDemo extends StatefulWidget {
  const CarouselDemo({super.key});

  @override
  State<CarouselDemo> createState() => _CarouselDemoState();
}

class _CarouselDemoState extends State<CarouselDemo> {
  late ImageCarouselController _sharedController;

  final List<String> _images = [
    'https://picsum.photos/400/200?random=1',
    'https://picsum.photos/400/200?random=2',
    'https://picsum.photos/400/200?random=3',
    'https://picsum.photos/400/200?random=4',
    'https://picsum.photos/400/200?random=5',
  ];

  @override
  void initState() {
    super.initState();
    _sharedController = ImageCarouselController();
  }

  @override
  void dispose() {
    _sharedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片轮播器演示'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '图片轮播器功能演示',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '展示图片轮播器的各种功能和配置选项',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // 基础轮播图
            const Text(
              '基础轮播图',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ImageCarousel(
                images: _images,
                options: const ImageCarouselOptions(
                  autoPlay: false,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),

            // 自动播放的轮播图
            const Text(
              '自动播放的轮播图',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ImageCarousel(
                images: _images,
                options: const ImageCarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),

            // 带点击事件的轮播图
            const Text(
              '带点击事件的轮播图',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ImageCarousel(
                images: _images,
                options: const ImageCarouselOptions(
                  autoPlay: false,
                ),
                borderRadius: BorderRadius.circular(12),
                onImageTap: (image, index) {
                  showDialog(
                    context: context,
                    builder: (context) => ImageViewerDialog(
                      images: _images,
                      initialIndex: index,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 带缩放功能的轮播图
            const Text(
              '带缩放功能的轮播图',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ImageCarousel(
                images: _images,
                options: const ImageCarouselOptions(
                  autoPlay: false,
                  enableZoom: true,
                  minScale: 0.5,
                  maxScale: 3.0,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),

            // 带Hero动画的轮播图
            const Text(
              '带Hero动画的轮播图',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ImageCarousel(
                images: _images,
                options: const ImageCarouselOptions(
                  autoPlay: false,
                  enableHeroAnimation: true,
                  heroTagPrefix: 'carousel_demo',
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),

            // 带自定义占位符的轮播图
            const Text(
              '带自定义占位符的轮播图',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ImageCarousel(
                images: _images,
                options: const ImageCarouselOptions(
                  autoPlay: false,
                ),
                borderRadius: BorderRadius.circular(12),
                placeholder: Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('加载中...'),
                      ],
                    ),
                  ),
                ),
                errorWidget: Container(
                  color: Colors.red[100],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 8),
                        Text('加载失败'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 带自定义图片构建器的轮播图
            const Text(
              '带自定义图片构建器的轮播图',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ImageCarousel(
                images: _images,
                options: const ImageCarouselOptions(
                  autoPlay: false,
                ),
                borderRadius: BorderRadius.circular(12),
                imageBuilder: (image, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 共享控制器的轮播图
            const Text(
              '共享控制器的轮播图',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: ImageCarousel(
                images: _images,
                controller: _sharedController,
                options: const ImageCarouselOptions(
                  autoPlay: false,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _sharedController.previousPage(),
                  child: const Text('上一张'),
                ),
                ElevatedButton(
                  onPressed: () => _sharedController.nextPage(),
                  child: const Text('下一张'),
                ),
                ElevatedButton(
                  onPressed: () => _sharedController.jumpToPage(0),
                  child: const Text('第一张'),
                ),
                ElevatedButton(
                  onPressed: () => _sharedController.jumpToPage(_images.length - 1),
                  child: const Text('最后一张'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
