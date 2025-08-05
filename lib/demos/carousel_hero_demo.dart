import 'package:flutter/material.dart';
import '../widgets/image_carousel/image_carousel.dart';
import '../widgets/image_carousel/image_carousel_controller.dart';
import '../widgets/image_carousel/image_viewer_dialog.dart';

class CarouselHeroDemo extends StatefulWidget {
  const CarouselHeroDemo({super.key});

  @override
  State<CarouselHeroDemo> createState() => _CarouselHeroDemoState();
}

class _CarouselHeroDemoState extends State<CarouselHeroDemo> {
  final ImageCarouselController _controller = ImageCarouselController();
  
  final List<String> _images = [
    'https://picsum.photos/800/400?random=1',
    'https://picsum.photos/800/400?random=2',
    'https://picsum.photos/800/400?random=3',
    'https://picsum.photos/800/400?random=4',
    'https://picsum.photos/800/400?random=5',
  ];

  bool _enableHeroAnimation = true;
  String _heroTagPrefix = 'carousel_hero_demo';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('轮播图Hero动画演示'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.animation, color: Colors.purple),
                    const SizedBox(width: 8),
                    const Text('Hero动画效果', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '点击轮播图中的任意图片，将看到平滑的Hero动画过渡效果。'
                  '图片会从轮播图中的位置平滑过渡到全屏查看模式。',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          Container(
            height: 250,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ImageCarousel(
                images: _images,
                controller: _controller,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                height: 250,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(16),
                enableHeroAnimation: _enableHeroAnimation,
                heroTagPrefix: _heroTagPrefix,
                enableCache: true,
                enablePreload: true,
                preloadCount: 2,
                enableGestureControl: true,
                enableErrorRetry: true,
                maxRetryCount: 3,
                placeholder: Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('图片加载中...'),
                      ],
                    ),
                  ),
                ),
                errorWidget: Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.grey, size: 50),
                        SizedBox(height: 8),
                        Text('图片加载失败', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                onImageTap: (image, index) {
                  print('点击图片 - 索引: $index, 图片: $image');
                  print('控制器当前索引: ${_controller.currentIndex}');
                  ImageViewerDialog.show(
                    context,
                    images: _images,
                    initialIndex: index,
                    controller: _controller,
                    enableHeroAnimation: _enableHeroAnimation,
                    heroTagPrefix: _heroTagPrefix,
                  );
                },
                overlaysBuilder: (controller) => [
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _images.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: controller.currentIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '点击图片查看',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hero动画配置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('启用Hero动画'),
                    subtitle: const Text('点击图片时显示平滑的过渡动画'),
                    value: _enableHeroAnimation,
                    onChanged: (value) {
                      setState(() {
                        _enableHeroAnimation = value;

                      });
                    },
                  ),

                  ListTile(
                    title: const Text('Hero标签前缀'),
                    subtitle: Text('当前: $_heroTagPrefix'),
                    trailing: SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        style: const TextStyle(fontSize: 14),
                        onChanged: (value) {
                          setState(() {
                            _heroTagPrefix = value.isNotEmpty ? value : 'carousel_hero_demo';
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hero动画特性:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('• 平滑过渡: 图片从轮播图位置平滑过渡到全屏'),
                        Text('• 共享元素: 使用Hero组件实现共享元素动画'),
                        Text('• 自定义标签: 支持自定义Hero标签前缀'),
                        Text('• 开关控制: 可以启用/禁用Hero动画效果'),
                        Text('• 性能优化: 结合缓存系统，提供流畅体验'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 