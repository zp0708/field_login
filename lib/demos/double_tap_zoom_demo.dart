import 'package:flutter/material.dart';
import '../widgets/image_carousel/image_carousel.dart';
import '../widgets/image_carousel/models/carousel_options.dart';

/// 双击缩放功能演示页面
class DoubleTapZoomDemo extends StatefulWidget {
  const DoubleTapZoomDemo({super.key});

  @override
  State<DoubleTapZoomDemo> createState() => _DoubleTapZoomDemoState();
}

class _DoubleTapZoomDemoState extends State<DoubleTapZoomDemo> {
  // 配置选项
  late ImageCarouselOptions _options;

  // 当前缩放比例
  double _currentScale = 1.0;

  // 是否处于放大状态
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();

    // 初始化配置选项
    _options = const ImageCarouselOptions(
      enableZoom: true,
      enableDoubleTapZoom: true,
      doubleTapScale: 2.5,
      doubleTapZoomDuration: Duration(milliseconds: 400),
      doubleTapZoomCurve: Curves.easeOutBack,
      minScale: 0.5,
      maxScale: 4.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('双击缩放演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 功能说明
            _buildFeatureDescription(),
            const SizedBox(height: 24),

            // 轮播器演示
            _buildCarouselDemo(),
            const SizedBox(height: 24),

            // 状态显示
            _buildStatusDisplay(),
            const SizedBox(height: 24),

            // 控制按钮
            _buildControlButtons(),
            const SizedBox(height: 24),

            // 配置选项
            _buildConfigOptions(),
          ],
        ),
      ),
    );
  }

  /// 构建功能说明
  Widget _buildFeatureDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.zoom_in, size: 32, color: Colors.blue.shade600),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '双击缩放功能',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Text(
                      '智能的图片缩放交互体验',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '这个演示展示了图片轮播器的双击缩放功能。用户可以：\n'
            '• 双击图片放大到指定比例\n'
            '• 再次双击恢复到原始大小\n'
            '• 使用双指进行精细缩放\n'
            '• 拖拽移动已放大的图片\n'
            '• 享受流畅的动画过渡效果',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建轮播器演示
  Widget _buildCarouselDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎯 轮播器演示',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ImageCarousel(
              images: [
                'https://picsum.photos/600/400?random=1',
                'https://picsum.photos/600/400?random=2',
                'https://picsum.photos/600/400?random=3',
                'https://picsum.photos/600/400?random=4',
              ],
              options: _options,
              onImageTap: (controller, image, index) {
                _showSnackBar('点击了第 ${index + 1} 张图片');
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 构建状态显示
  Widget _buildStatusDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green.shade600),
              const SizedBox(width: 12),
              Text(
                '当前状态',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  '缩放比例',
                  '${_currentScale.toStringAsFixed(2)}x',
                  Icons.zoom_in,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatusItem(
                  '缩放状态',
                  _isZoomed ? '已放大' : '原始大小',
                  _isZoomed ? Icons.zoom_in : Icons.zoom_out,
                  _isZoomed ? Colors.orange : Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建状态项
  Widget _buildStatusItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建控制按钮
  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.control_camera, color: Colors.purple.shade600),
              const SizedBox(width: 12),
              Text(
                '控制操作',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => _updateScale(1.0),
                icon: const Icon(Icons.refresh),
                label: const Text('重置缩放'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _updateScale(2.0),
                icon: const Icon(Icons.zoom_in),
                label: const Text('放大2倍'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _updateScale(0.5),
                icon: const Icon(Icons.zoom_out),
                label: const Text('缩小0.5倍'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建配置选项
  Widget _buildConfigOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: Colors.amber.shade600),
              const SizedBox(width: 12),
              Text(
                '配置选项',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildConfigItem('双击缩放比例', '${_options.doubleTapScale}x'),
          _buildConfigItem('动画时长', '${_options.doubleTapZoomDuration.inMilliseconds}ms'),
          _buildConfigItem('最小缩放', '${_options.minScale}x'),
          _buildConfigItem('最大缩放', '${_options.maxScale}x'),
          _buildConfigItem('启用缩放', _options.enableZoom ? '是' : '否'),
          _buildConfigItem('启用双击缩放', _options.enableDoubleTapZoom ? '是' : '否'),
        ],
      ),
    );
  }

  /// 构建配置项
  Widget _buildConfigItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber.shade700,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 更新缩放比例
  void _updateScale(double scale) {
    setState(() {
      _currentScale = scale;
      _isZoomed = scale != 1.0;
    });

    _showSnackBar('缩放比例已更新为 ${scale.toStringAsFixed(1)}x');
  }

  /// 显示提示信息
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
