import 'package:flutter/material.dart';
import '../widgets/image_carousel/image_carousel.dart';
import '../widgets/image_carousel/image_viewer_dialog.dart';
import '../widgets/image_carousel/models/carousel_options.dart';

class IndexTestDemo extends StatefulWidget {
  const IndexTestDemo({super.key});

  @override
  State<IndexTestDemo> createState() => _IndexTestDemoState();
}

class _IndexTestDemoState extends State<IndexTestDemo> {
  final List<String> _images = [
    'https://picsum.photos/400/200?random=1',
    'https://picsum.photos/400/200?random=2',
    'https://picsum.photos/400/200?random=3',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('索引测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '索引测试 - 检查点击的图片索引是否正确',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ImageCarousel(
                  images: _images,
                  options: const ImageCarouselOptions(
                    autoPlay: false,
                    enableHeroAnimation: true,
                    heroTagPrefix: 'test_index',
                  ),
                  borderRadius: BorderRadius.circular(12),
                  onImageTap: (controller, image, index) {
                    // 显示索引信息
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('索引信息'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('点击的图片URL: $image'),
                            Text('传递的索引: $index'),
                            Text('控制器当前索引: ${controller.currentIndex}'),
                            Text('图片列表长度: ${_images.length}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('关闭'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ImageViewerDialog.show(
                                context,
                                images: _images,
                                initialIndex: index,
                                enableHeroAnimation: true,
                                heroTagPrefix: 'test_index',
                              );
                            },
                            child: const Text('打开预览'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '点击图片查看索引信息，然后点击"打开预览"测试预览功能',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
