import 'package:flutter/material.dart';
import '../widgets/image_carousel/image_carousel.dart';
import '../widgets/image_carousel/image_carousel_controller.dart';
import '../widgets/image_carousel/carousel_indicator.dart';
import '../widgets/image_carousel/image_viewer_dialog.dart';

class CarouselDemo extends StatefulWidget {
  const CarouselDemo({super.key});

  @override
  State<CarouselDemo> createState() => _CarouselDemoState();
}

class _CarouselDemoState extends State<CarouselDemo> {
  final ImageCarouselController _sharedController = ImageCarouselController();
  CarouselIndicatorType _indicatorType = CarouselIndicatorType.dots;
  bool _autoPlay1 = false;
  bool _autoPlay2 = false;

  final List<String> _images = [
    'https://picsum.photos/400/200?random=1',
    'https://picsum.photos/400/200?random=2',
    'https://picsum.photos/400/200?random=3',
    'https://picsum.photos/400/200?random=4',
    'https://picsum.photos/400/200?random=5',
  ];

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. 基础轮播器（无限滚动）'),
            ImageCarousel(
              images: _images,
              height: 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 2),
              borderRadius: BorderRadius.circular(12),
              infiniteScroll: true,
              onImageViewer: (index) {
                ImageViewerDialog.showFromCarousel(
                  context,
                  images: _images,
                  initialIndex: index,
                  carouselController: _sharedController,
                );
              },
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('2. 普通模式（非无限滚动）'),
            ImageCarousel(
              images: _images,
              height: 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              borderRadius: BorderRadius.circular(12),
              infiniteScroll: false,
              onImageViewer: (index) {
                ImageViewerDialog.showFromCarousel(
                  context,
                  images: _images,
                  initialIndex: index,
                  carouselController: _sharedController,
                );
              },
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('3. 自定义指示器'),
            _buildIndicatorTypeSelector(),
            const SizedBox(height: 16),
            ImageCarousel(
              images: _images,
              height: 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              indicatorType: _indicatorType,
              indicatorActiveColor: Colors.blue,
              indicatorInactiveColor: Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('4. 共享控制器'),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildControlButtons(_autoPlay1, (value) {
                        setState(() => _autoPlay1 = value);
                      }),
                      const SizedBox(height: 8),
                      ImageCarousel(
                        images: _images,
                        infiniteScroll: true,
                        height: 150,
                        controller: _sharedController,
                        autoPlay: _autoPlay1,
                        autoPlayInterval: const Duration(seconds: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildControlButtons(_autoPlay2, (value) {
                        setState(() => _autoPlay2 = value);
                      }),
                      const SizedBox(height: 8),
                      ImageCarousel(
                        images: _images,
                        height: 150,
                        infiniteScroll: true,
                        controller: _sharedController,
                        autoPlay: _autoPlay2,
                        autoPlayInterval: const Duration(seconds: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('5. 控制器操作'),
            _buildControllerButtons(),
            const SizedBox(height: 16),
            ImageCarousel(
              images: _images,
              height: 200,
              controller: _sharedController,
              autoPlay: false,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIndicatorTypeSelector() {
    return Row(
      children: [
        const Text('指示器类型: '),
        const SizedBox(width: 8),
        DropdownButton<CarouselIndicatorType>(
          value: _indicatorType,
          items: CarouselIndicatorType.values.map((type) {
            String label;
            switch (type) {
              case CarouselIndicatorType.dots:
                label = '圆点';
                break;
              case CarouselIndicatorType.numbers:
                label = '数字';
                break;
              case CarouselIndicatorType.lines:
                label = '线条';
                break;
            }
            return DropdownMenuItem(
              value: type,
              child: Text(label),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _indicatorType = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildControlButtons(bool autoPlay, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('自动播放: '),
        Switch(
          value: autoPlay,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildControllerButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton(
          onPressed: () => _sharedController.previousPage(),
          child: const Text('上一页'),
        ),
        ElevatedButton(
          onPressed: () => _sharedController.nextPage(),
          child: const Text('下一页'),
        ),
        ElevatedButton(
          onPressed: () => _sharedController.jumpToPage(0),
          child: const Text('跳转到第一页'),
        ),
        ElevatedButton(
          onPressed: () => _sharedController.jumpToPage(_images.length - 1),
          child: const Text('跳转到最后一页'),
        ),
        ElevatedButton(
          onPressed: () => _sharedController.toggleAutoPlay(),
          child: Text(_sharedController.isAutoPlaying ? '停止自动播放' : '开始自动播放'),
        ),
      ],
    );
  }
} 