import 'package:flutter/material.dart';
import '../widgets/image_carousel/image_carousel.dart';
import '../widgets/image_carousel/image_carousel_controller.dart';
import '../widgets/image_carousel/image_viewer_dialog.dart';
import '../widgets/image_carousel/models/carousel_options.dart';
import '../widgets/image_carousel/overlays/carousel_indicator.dart';
import '../widgets/image_carousel/overlays/indicator_overlay.dart';
import '../widgets/image_carousel/overlays/page_counter_overlay.dart';
import '../widgets/image_carousel/overlays/control_buttons_overlay.dart';

class CarouselDemo extends StatefulWidget {
  const CarouselDemo({super.key});

  @override
  State<CarouselDemo> createState() => _CarouselDemoState();
}

class _CarouselDemoState extends State<CarouselDemo> {
  late ImageCarouselController _sharedController;
  late ImageCarouselController _advancedController;

  // 配置状态
  bool _autoPlay = false;
  bool _enableZoom = false;
  bool _enableHeroAnimation = false;
  bool _showOverlays = true;
  double _autoPlayInterval = 3.0;
  double _minScale = 0.5;
  double _maxScale = 3.0;

  final List<String> _images = [
    'https://picsum.photos/400/200?random=1',
    'https://picsum.photos/400/200?random=2',
    'https://picsum.photos/400/200?random=3',
    'https://picsum.photos/400/200?random=4',
    'https://picsum.photos/400/200?random=5',
    'https://picsum.photos/400/200?random=6',
    'https://picsum.photos/400/200?random=7',
  ];

  @override
  void initState() {
    super.initState();
    _sharedController = ImageCarouselController();
    _advancedController = ImageCarouselController();
  }

  @override
  void dispose() {
    _sharedController.dispose();
    _advancedController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.settings, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('配置面板'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: _buildConfigContent(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('自动播放'),
          subtitle: const Text('启用自动轮播功能'),
          value: _autoPlay,
          onChanged: (value) => setState(() => _autoPlay = value),
          activeColor: Colors.blue,
        ),
        if (_autoPlay) ...[
          ListTile(
            title: const Text('播放间隔'),
            subtitle: Slider(
              value: _autoPlayInterval,
              min: 1.0,
              max: 10.0,
              divisions: 9,
              label: '${_autoPlayInterval.toStringAsFixed(1)}秒',
              onChanged: (value) => setState(() => _autoPlayInterval = value),
              activeColor: Colors.blue,
              thumbColor: Colors.blue,
            ),
          ),
        ],
        SwitchListTile(
          title: const Text('缩放功能'),
          subtitle: const Text('支持双指缩放图片'),
          value: _enableZoom,
          onChanged: (value) => setState(() => _enableZoom = value),
          activeColor: Colors.blue,
        ),
        if (_enableZoom) ...[
          ListTile(
            title: const Text('最小缩放'),
            subtitle: Slider(
              value: _minScale,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: _minScale.toStringAsFixed(1),
              onChanged: (value) => setState(() => _minScale = value),
              activeColor: Colors.blue,
              thumbColor: Colors.blue,
            ),
          ),
          ListTile(
            title: const Text('最大缩放'),
            subtitle: Slider(
              value: _maxScale,
              min: 1.0,
              max: 5.0,
              divisions: 8,
              label: _maxScale.toStringAsFixed(1),
              onChanged: (value) => setState(() => _maxScale = value),
              activeColor: Colors.blue,
              thumbColor: Colors.blue,
            ),
          ),
        ],
        SwitchListTile(
          title: const Text('Hero动画'),
          subtitle: const Text('启用Hero过渡动画'),
          value: _enableHeroAnimation,
          onChanged: (value) => setState(() => _enableHeroAnimation = value),
          activeColor: Colors.blue,
        ),
        SwitchListTile(
          title: const Text('显示覆盖层'),
          subtitle: const Text('显示指示器和控制按钮'),
          value: _showOverlays,
          onChanged: (value) => setState(() => _showOverlays = value),
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图片轮播器演示'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () => _showConfigDialog(context),
            icon: Icon(Icons.settings),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和描述
            _buildHeader(),
            const SizedBox(height: 24),

            // 高级演示轮播图
            _buildAdvancedDemo(),
            const SizedBox(height: 24),

            // 基础轮播图
            _buildBasicDemo(),
            const SizedBox(height: 24),

            // 自动播放轮播图
            _buildAutoPlayDemo(),
            const SizedBox(height: 24),

            // 缩放功能轮播图
            _buildZoomDemo(),
            const SizedBox(height: 24),

            // Hero动画轮播图
            _buildHeroDemo(),
            const SizedBox(height: 24),

            // 自定义UI轮播图
            _buildCustomUIDemo(),
            const SizedBox(height: 24),

            // 覆盖层演示
            _buildOverlayDemo(),
            const SizedBox(height: 24),

            // 控制器演示
            _buildControllerDemo(),
            const SizedBox(height: 24),

            // 错误处理演示
            _buildErrorDemo(),
            const SizedBox(height: 24),

            // 滑动测试演示
            _buildSwipeTestDemo(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '🎠 图片轮播器功能演示',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '展示图片轮播器的各种功能和配置选项，包括自动播放、手势控制、Hero动画、覆盖层系统等',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎯 高级演示（实时配置）',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ImageCarousel(
              images: _images,
              controller: _advancedController,
              options: ImageCarouselOptions(
                autoPlay: _autoPlay,
                autoPlayInterval: Duration(seconds: _autoPlayInterval.round()),
                enableZoom: _enableZoom,
                minScale: _minScale,
                maxScale: _maxScale,
                enableHeroAnimation: _enableHeroAnimation,
                enableCache: true,
                enablePreload: true,
                preloadCount: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              placeholder: Container(
                color: Colors.grey.shade200,
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
                color: Colors.red.shade100,
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
              onImageTap: (controller, image, index) {
                ImageViewerDialog.show(
                  context,
                  images: _images,
                  initialIndex: index,
                  controller: controller,
                  enableHeroAnimation: _enableHeroAnimation,
                );
              },
              overlaysBuilder: _showOverlays
                  ? (controller) => [
                        // 指示器
                        IndicatorOverlay(
                          controller: controller,
                          type: CarouselIndicatorType.dots,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white.withOpacity(0.5),
                        ),
                        // 页码显示
                        PageCounterOverlay(
                          controller: controller,
                          backgroundColor: Colors.black54,
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // 控制按钮
                        ControlButtonsOverlay(
                          controller: controller,
                          buttonSize: 36,
                          backgroundColor: Colors.black54,
                          buttonColor: Colors.white,
                        ),
                      ]
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _advancedController.previousPage(),
              icon: const Icon(Icons.chevron_left),
              label: const Text('上一张'),
            ),
            ElevatedButton.icon(
              onPressed: () => _advancedController.nextPage(),
              icon: const Icon(Icons.chevron_right),
              label: const Text('下一张'),
            ),
            ElevatedButton.icon(
              onPressed: () => _advancedController.jumpToPage(0),
              icon: const Icon(Icons.first_page),
              label: const Text('第一张'),
            ),
            ElevatedButton.icon(
              onPressed: () => _advancedController.jumpToPage(_images.length - 1),
              icon: const Icon(Icons.last_page),
              label: const Text('最后一张'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📱 基础轮播图',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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
              ),
              borderRadius: BorderRadius.circular(12),
              onImageTap: (controller, image, index) {
                _showSnackBar('点击了第 ${index + 1} 张图片');
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoPlayDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔄 自动播放轮播图',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
              ),
              borderRadius: BorderRadius.circular(12),
              onImageTap: (controller, image, index) {
                _showSnackBar('支持双指缩放，点击查看大图');
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZoomDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔍 缩放功能轮播图',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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
                enableZoom: true,
                minScale: 0.5,
                maxScale: 3.0,
              ),
              borderRadius: BorderRadius.circular(12),
              onImageTap: (controller, image, index) {
                _showSnackBar('支持双指缩放，点击查看大图');
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🦸 Hero动画轮播图',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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
                heroTagPrefix: 'hero_demo',
              ),
              borderRadius: BorderRadius.circular(12),
              onImageTap: (controller, image, index) {
                ImageViewerDialog.show(
                  context,
                  images: _images,
                  initialIndex: index,
                  enableHeroAnimation: true,
                  heroTagPrefix: 'hero_demo',
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomUIDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎨 自定义UI轮播图',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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
              ),
              borderRadius: BorderRadius.circular(12),
              placeholder: Container(
                color: Colors.grey.shade200,
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
                color: Colors.red.shade100,
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
                    child: Stack(
                      children: [
                        Image.network(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${index + 1}/${_images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏗️ 覆盖层系统演示',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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
              ),
              borderRadius: BorderRadius.circular(12),
              overlaysBuilder: (controller) => [
                // 顶部标题
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListenableBuilder(
                      listenable: controller,
                      builder: (context, child) {
                        return Text(
                          '图片 ${controller.currentIndex + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // 底部指示器
                IndicatorOverlay(
                  controller: controller,
                  type: CarouselIndicatorType.dots,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.5),
                ),
                // 控制按钮
                ControlButtonsOverlay(
                  controller: controller,
                  buttonSize: 40,
                  backgroundColor: Colors.black54,
                  buttonColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControllerDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎮 控制器演示',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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
              controller: _sharedController,
              options: const ImageCarouselOptions(
                autoPlay: false,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _sharedController.previousPage(),
              icon: const Icon(Icons.chevron_left),
              label: const Text('上一张'),
            ),
            ElevatedButton.icon(
              onPressed: () => _sharedController.nextPage(),
              icon: const Icon(Icons.chevron_right),
              label: const Text('下一张'),
            ),
            ElevatedButton.icon(
              onPressed: () => _sharedController.jumpToPage(0),
              icon: const Icon(Icons.first_page),
              label: const Text('第一张'),
            ),
            ElevatedButton.icon(
              onPressed: () => _sharedController.jumpToPage(_images.length - 1),
              icon: const Icon(Icons.last_page),
              label: const Text('最后一张'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _sharedController.startAutoPlay(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('开始播放'),
            ),
            ElevatedButton.icon(
              onPressed: () => _sharedController.stopAutoPlay(),
              icon: const Icon(Icons.stop),
              label: const Text('停止播放'),
            ),
            ElevatedButton.icon(
              onPressed: () => _sharedController.toggleAutoPlay(),
              icon: const Icon(Icons.pause),
              label: const Text('切换播放'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '❌ 错误处理演示',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ImageCarousel(
              images: [
                'https://invalid-url-1.com/image.jpg',
                'https://invalid-url-2.com/image.jpg',
                'https://picsum.photos/400/200?random=1',
              ],
              options: const ImageCarouselOptions(
                autoPlay: false,
                enableErrorRetry: true,
              ),
              borderRadius: BorderRadius.circular(12),
              errorWidget: Container(
                color: Colors.red.shade100,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 8),
                      Text('图片加载失败'),
                      SizedBox(height: 8),
                      Text('点击重试'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeTestDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '👆 滑动测试演示',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
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
                enableGestureControl: true,
              ),
              borderRadius: BorderRadius.circular(12),
              onImageTap: (controller, image, index) {
                _showSnackBar('当前索引: ${controller.currentIndex + 1}');
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '💡 提示：左右滑动切换图片，点击图片查看当前索引',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
