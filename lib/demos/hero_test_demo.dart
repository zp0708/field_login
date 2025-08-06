import 'package:flutter/material.dart';
import '../widgets/image_carousel/image_carousel.dart';
import '../widgets/image_carousel/image_viewer_dialog.dart';
import '../widgets/image_carousel/models/carousel_options.dart';

class HeroTestDemo extends StatefulWidget {
  const HeroTestDemo({super.key});

  @override
  State<HeroTestDemo> createState() => _HeroTestDemoState();
}

class _HeroTestDemoState extends State<HeroTestDemo> {
  final List<String> _images = [
    'https://picsum.photos/400/200?random=1',
    'https://picsum.photos/400/200?random=2',
    'https://picsum.photos/400/200?random=3',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero动画测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hero动画测试',
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
                    heroTagPrefix: 'test_hero',
                  ),
                  borderRadius: BorderRadius.circular(12),
                  onImageTap: (controller, image, index) {
                    ImageViewerDialog.show(
                      context,
                      images: _images,
                      initialIndex: index,
                      enableHeroAnimation: true,
                      heroTagPrefix: 'test_hero',
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '点击上面的图片测试Hero动画效果',
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
