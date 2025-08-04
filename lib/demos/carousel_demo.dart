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
  bool _enableZoom = false;
  bool _enablePreload = true;
  bool _enableErrorRetry = true;

  final List<String> _images = [
    'https://picsum.photos/400/200?random=1',
    'https://picsum.photos/400/200?random=2',
    'https://picsum.photos/400/200?random=3',
    'https://picsum.photos/400/200?random=4',
    'https://picsum.photos/400/200?random=5',
  ];

  // 包含错误图片的列表，用于测试错误重试功能
  final List<String> _imagesWithErrors = [
    'https://picsum.photos/400/200?random=1',
    'https://invalid-url-that-will-fail.com/image.jpg', // 错误图片
    'https://picsum.photos/400/200?random=3',
    'https://another-invalid-url.com/image.jpg', // 错误图片
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
              autoPlay: false,
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
              autoPlay: false,
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
            const SizedBox(height: 24),
            _buildSectionTitle('6. 缩放功能'),
            _buildZoomControls(),
            const SizedBox(height: 16),
            ImageCarousel(
              images: _images,
              height: 200,
              autoPlay: false,
              enableZoom: _enableZoom,
              minScale: 0.5,
              maxScale: 3.0,
              borderRadius: BorderRadius.circular(12),
              onImageViewer: (index) {
                ImageViewerDialog.show(
                  context,
                  images: _images,
                  initialIndex: index,
                );
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('7. 错误重试功能'),
            _buildErrorRetryControls(),
            const SizedBox(height: 16),
            ImageCarousel(
              images: _imagesWithErrors,
              height: 200,
              autoPlay: false,
              enableErrorRetry: _enableErrorRetry,
              maxRetryCount: 3,
              retryDelay: const Duration(seconds: 2),
              borderRadius: BorderRadius.circular(12),
              errorWidget: Container(
                color: Colors.red[100],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 40),
                    SizedBox(height: 8),
                    Text('图片加载失败', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('8. 预加载功能'),
            _buildPreloadControls(),
            const SizedBox(height: 16),
            ImageCarousel(
              images: _images,
              height: 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 2),
              enablePreload: _enablePreload,
              preloadCount: 2,
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
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('9. 高级指示器'),
            _buildAdvancedIndicatorDemo(),
            const SizedBox(height: 16),
            ImageCarousel(
              images: _images,
              height: 200,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              borderRadius: BorderRadius.circular(12),
              indicatorType: CarouselIndicatorType.progress,
              indicatorActiveColor: Colors.green,
              indicatorInactiveColor: Colors.grey[300],
              indicatorSize: 12,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('10. 进度条指示器测试'),
            _buildProgressIndicatorTest(),
            const SizedBox(height: 24),
            _buildSectionTitle('11. 约束测试'),
            _buildConstraintTest(),
            const SizedBox(height: 24),
            _buildSectionTitle('12. 控制器状态信息'),
            _buildStatusInfo(),
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
              case CarouselIndicatorType.progress:
                label = '进度条';
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
        ElevatedButton(
          onPressed: () => _sharedController.togglePause(),
          child: Text(_sharedController.isPaused ? '恢复播放' : '暂停播放'),
        ),
      ],
    );
  }

  Widget _buildZoomControls() {
    return Row(
      children: [
        const Text('启用缩放: '),
        Switch(
          value: _enableZoom,
          onChanged: (value) {
            setState(() => _enableZoom = value);
          },
        ),
        const SizedBox(width: 16),
        if (_enableZoom) const Text('双击图片可缩放', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildErrorRetryControls() {
    return Row(
      children: [
        const Text('启用错误重试: '),
        Switch(
          value: _enableErrorRetry,
          onChanged: (value) {
            setState(() => _enableErrorRetry = value);
          },
        ),
        const SizedBox(width: 16),
        if (_enableErrorRetry) const Text('点击重试按钮重新加载', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildPreloadControls() {
    return Row(
      children: [
        const Text('启用预加载: '),
        Switch(
          value: _enablePreload,
          onChanged: (value) {
            setState(() => _enablePreload = value);
          },
        ),
        const SizedBox(width: 16),
        if (_enablePreload) const Text('预加载前后2张图片', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildAdvancedIndicatorDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('进度条指示器示例'),
        const SizedBox(height: 8),
        CarouselIndicator(
          currentIndex: _sharedController.currentIndex,
          totalCount: _sharedController.totalCount,
          type: CarouselIndicatorType.progress,
          activeColor: Colors.blue,
          inactiveColor: Colors.grey[300],
          size: 8,
          enableAnimation: true,
          animationDuration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }

  Widget _buildProgressIndicatorTest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('进度条指示器在不同布局中的测试'),
        const SizedBox(height: 16),

        // 测试1: 在Row中使用
        const Text('在Row中使用:'),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('进度: '),
            Expanded(
              child: SizedBox(
                height: 4,
                child: CarouselIndicator(
                  currentIndex: _sharedController.currentIndex,
                  totalCount: _sharedController.totalCount,
                  type: CarouselIndicatorType.progress,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey[300]!,
                  size: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 测试2: 在Column中直接使用
        const Text('在Column中直接使用:'),
        const SizedBox(height: 8),
        SizedBox(
          height: 6,
          child: CarouselIndicator(
            currentIndex: _sharedController.currentIndex,
            totalCount: _sharedController.totalCount,
            type: CarouselIndicatorType.progress,
            activeColor: Colors.green,
            inactiveColor: Colors.grey[300]!,
            size: 12,
          ),
        ),
        const SizedBox(height: 16),

        // 测试3: 在Container中限制宽度
        const Text('在Container中限制宽度:'),
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          height: 5,
          child: CarouselIndicator(
            currentIndex: _sharedController.currentIndex,
            totalCount: _sharedController.totalCount,
            type: CarouselIndicatorType.progress,
            activeColor: Colors.red,
            inactiveColor: Colors.grey[300]!,
            size: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildConstraintTest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('约束测试 - 测试轮播器在各种布局约束下的表现'),
        const SizedBox(height: 16),

        // 基础功能测试
        const Text('基础轮播器测试:'),
        const SizedBox(height: 8),
        ImageCarousel(
          images: _images,
          height: 150,
          autoPlay: false,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 16),

        // 缩放功能测试
        const Text('缩放功能测试:'),
        const SizedBox(height: 8),
        ImageCarousel(
          images: _images,
          height: 150,
          autoPlay: false,
          enableZoom: true,
          minScale: 0.5,
          maxScale: 3.0,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 16),

        // 错误处理测试
        const Text('错误处理测试:'),
        const SizedBox(height: 8),
        ImageCarousel(
          images: _imagesWithErrors,
          height: 150,
          autoPlay: false,
          enableErrorRetry: true,
          maxRetryCount: 3,
          retryDelay: const Duration(seconds: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 16),

        // 预加载测试
        const Text('预加载测试:'),
        const SizedBox(height: 8),
        ImageCarousel(
          images: _images,
          height: 150,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 2),
          enablePreload: true,
          preloadCount: 2,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 16),

        // 进度条指示器测试
        const Text('进度条指示器测试:'),
        const SizedBox(height: 8),
        ImageCarousel(
          images: _images,
          height: 150,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          borderRadius: BorderRadius.circular(8),
          indicatorType: CarouselIndicatorType.progress,
          indicatorActiveColor: Colors.green,
          indicatorInactiveColor: Colors.grey[300],
          indicatorSize: 12,
        ),
      ],
    );
  }

  Widget _buildStatusInfo() {
    return ListenableBuilder(
      listenable: _sharedController,
      builder: (context, child) {
        final status = _sharedController.getStatus();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('当前索引: ${status['currentIndex']}'),
              Text('总数量: ${status['totalCount']}'),
              Text('自动播放: ${status['isAutoPlaying']}'),
              Text('暂停状态: ${status['isPaused']}'),
              Text('播放间隔: ${status['autoPlayInterval']}ms'),
              Text('进度: ${(status['progress'] * 100).toStringAsFixed(1)}%'),
              if (status['lastUserInteraction'] != null)
                Text('最后交互: ${DateTime.fromMillisecondsSinceEpoch(status['lastUserInteraction']).toString()}'),
            ],
          ),
        );
      },
    );
  }
}
