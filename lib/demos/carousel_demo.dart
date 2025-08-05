import 'package:flutter/material.dart';
import '../widgets/image_carousel/image_carousel.dart';
import '../widgets/image_carousel/image_carousel_controller.dart';
import '../widgets/image_carousel/overlays/indicator_overlay.dart';
import '../widgets/image_carousel/overlays/page_counter_overlay.dart';
import '../widgets/image_carousel/overlays/control_buttons_overlay.dart';
import '../widgets/image_carousel/overlays/carousel_indicator.dart';
import '../widgets/image_carousel/image_viewer_dialog.dart';

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
        title: const Text('轮播图覆盖层演示'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '覆盖层系统演示',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '展示如何使用不同的覆盖层来扩展轮播图功能',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // 基础轮播图（无覆盖层）
            const Text(
              '基础轮播图（无覆盖层）',
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
                autoPlay: false,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),

            // 带指示器覆盖层的轮播图
            const Text(
              '带指示器覆盖层的轮播图',
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
                autoPlay: false,
                enableHeroAnimation: true,
                borderRadius: BorderRadius.circular(12),
                overlaysBuilder: (controller) => [
                  IndicatorOverlay(
                    controller: controller,
                    type: CarouselIndicatorType.dots,
                    activeColor: Colors.red,
                    inactiveColor: Colors.grey,
                  ),
                ],
                onImageTap: (image, index) {
                  ImageViewerDialog.show(
                    context, 
                    images: _images,
                    initialIndex: index, 
                    enableHeroAnimation: true,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 带页码显示覆盖层的轮播图
            const Text(
              '带页码显示覆盖层的轮播图',
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
                autoPlay: false,
                borderRadius: BorderRadius.circular(12),
                overlaysBuilder: (controller) => [
                  PageCounterOverlay(
                    controller: controller,
                    backgroundColor: Colors.black54,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 带控制按钮覆盖层的轮播图
            const Text(
              '带控制按钮覆盖层的轮播图',
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
                autoPlay: false,
                borderRadius: BorderRadius.circular(12),
                overlaysBuilder: (controller) => [
                  ControlButtonsOverlay(
                    controller: controller,
                    buttonSize: 40,
                    backgroundColor: Colors.black54,
                    buttonColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 多覆盖层组合的轮播图
            const Text(
              '多覆盖层组合的轮播图',
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
                autoPlay: false,
                borderRadius: BorderRadius.circular(12),
                overlaysBuilder: (controller) => [
                  IndicatorOverlay(
                    controller: controller,
                    type: CarouselIndicatorType.progress,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey,
                    size: 8,
                  ),
                  PageCounterOverlay(
                    controller: controller,
                    backgroundColor: Colors.black54,
                  ),
                  ControlButtonsOverlay(
                    controller: controller,
                    buttonSize: 36,
                    backgroundColor: Colors.black54,
                    buttonColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 共享控制器的轮播图
            const Text(
              '共享控制器的轮播图（覆盖层同步测试）',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '快速滑动任意一个轮播图，其他轮播图应该同步滑动相同的次数',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // 第一个共享控制器的轮播图
            const Text(
              '轮播图 1',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ImageCarousel(
                images: _images,
                controller: _sharedController,
                autoPlay: false,
                borderRadius: BorderRadius.circular(12),
                enableHeroAnimation: true,
                heroTagPrefix: 'carousel_demo',
                overlaysBuilder: (controller) => [
                  IndicatorOverlay(
                    controller: controller,
                    type: CarouselIndicatorType.dots,
                    activeColor: Colors.blue,
                  ),
                ],
                onImageTap: (image, index) {
                  print('image: $image, index: $index');
                  ImageViewerDialog.show(
                    context, 
                    images: _images,
                    initialIndex: index, 
                    controller: _sharedController,
                    enableHeroAnimation: true,
                    heroTagPrefix: 'carousel_demo',
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 第二个共享控制器的轮播图
            const Text(
              '轮播图 2',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ImageCarousel(
                images: _images,
                controller: _sharedController,
                autoPlay: false,
                borderRadius: BorderRadius.circular(12),
                overlaysBuilder: (controller) => [
                  PageCounterOverlay(
                    controller: controller,
                    backgroundColor: Colors.black54,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 第三个共享控制器的轮播图
            const Text(
              '轮播图 3',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ImageCarousel(
                images: _images,
                controller: _sharedController,
                autoPlay: false,
                borderRadius: BorderRadius.circular(12),
                overlaysBuilder: (controller) => [
                  ControlButtonsOverlay(
                    controller: controller,
                    buttonSize: 32,
                    backgroundColor: Colors.black54,
                    buttonColor: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 控制按钮
            Wrap(
              spacing: 10,
              runSpacing: 10,
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
              ],
            ),
            const SizedBox(height: 16),

            // 状态显示
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListenableBuilder(
                listenable: _sharedController,
                builder: (context, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '控制器状态:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('当前索引: ${_sharedController.currentIndex + 1}'),
                      Text('总数量: ${_sharedController.totalCount}'),
                      Text('自动播放: ${_sharedController.isAutoPlaying}'),
                      Text('暂停状态: ${_sharedController.isPaused}'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
