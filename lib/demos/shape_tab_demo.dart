import 'package:flutter/material.dart';
import '../widgets/shape_tab_widget/shape_tab_widget.dart';

class ShapeTabDemo extends StatefulWidget {
  const ShapeTabDemo({super.key});

  @override
  State<ShapeTabDemo> createState() => _ShapeTabDemoState();
}

class _ShapeTabDemoState extends State<ShapeTabDemo> {
  final int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('形状标签组件演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ShapeTabWidget 形状标签组件',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // 形状标签组件
            ShapeTabWidget(
              titles: const [
                '标签1',
                '标签2',
                '标签3',
                '标签4',
              ],
            ),
            const SizedBox(height: 30),

            // 显示选中的标签
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '当前选中的标签:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '标签${_selectedIndex + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 功能说明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '功能特性:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem('自定义形状'),
                    _buildFeatureItem('多种样式'),
                    _buildFeatureItem('灵活配置'),
                    _buildFeatureItem('动画效果'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 8),
          Text(feature),
        ],
      ),
    );
  }
}
