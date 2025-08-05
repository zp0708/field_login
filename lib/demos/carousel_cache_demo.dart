import 'package:flutter/material.dart';
import '../widgets/image_carousel/image_carousel.dart';
import '../widgets/image_carousel/image_carousel_controller.dart';

class CarouselCacheDemo extends StatefulWidget {
  const CarouselCacheDemo({super.key});

  @override
  State<CarouselCacheDemo> createState() => _CarouselCacheDemoState();
}

class _CarouselCacheDemoState extends State<CarouselCacheDemo> {
  final ImageCarouselController _controller = ImageCarouselController();
  
  final List<String> _images = [
    'https://picsum.photos/800/400?random=1',
    'https://picsum.photos/800/400?random=2',
    'https://picsum.photos/800/400?random=3',
    'https://picsum.photos/800/400?random=4',
    'https://picsum.photos/800/400?random=5',
  ];

  bool _enableCache = true;
  bool _enablePreload = true;
  int _preloadCount = 2;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('轮播图缓存功能演示'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ImageCarousel(
                images: _images,
                controller: _controller,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                height: 300,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
                enableCache: _enableCache,
                enablePreload: _enablePreload,
                preloadCount: _preloadCount,
                memCacheWidth: 800,
                memCacheHeight: 600,
                maxWidthDiskCache: 1024,
                maxHeightDiskCache: 768,
                useOldImageOnUrlChange: true,
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
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${controller.currentIndex + 1}/${_images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
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
                  const Text(
                    '缓存配置',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('启用图片缓存'),
                    subtitle: const Text('使用 CachedNetworkImage 进行图片缓存'),
                    value: _enableCache,
                    onChanged: (value) {
                      setState(() {
                        _enableCache = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('启用预加载'),
                    subtitle: const Text('预加载前后图片以提高切换速度'),
                    value: _enablePreload,
                    onChanged: (value) {
                      setState(() {
                        _enablePreload = value;
                      });
                    },
                  ),
                  ListTile(
                    title: const Text('预加载数量'),
                    subtitle: Text('当前: $_preloadCount 张'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _preloadCount > 1
                              ? () {
                                  setState(() {
                                    _preloadCount--;
                                  });
                                }
                              : null,
                        ),
                        Text('$_preloadCount'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _preloadCount < 5
                              ? () {
                                  setState(() {
                                    _preloadCount++;
                                  });
                                }
                              : null,
                        ),
                      ],
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
                        Text('缓存功能特性:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('• 内存缓存: 图片存储在内存中，快速访问'),
                        Text('• 磁盘缓存: 图片存储在设备磁盘上，持久化'),
                        Text('• 预加载: 提前加载前后图片，提升切换体验'),
                        Text('• 错误重试: 加载失败时自动重试'),
                        Text('• 自定义缓存键: 避免缓存冲突'),
                        Text('• 缓存大小控制: 优化内存使用'),
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