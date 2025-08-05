import 'package:flutter/material.dart';
import '../demos/carousel_demo.dart';
import '../demos/carousel_cache_demo.dart';
import '../demos/carousel_hero_demo.dart';
import '../demos/hero_test_demo.dart';
import '../demos/progress_demo.dart';
import '../demos/phone_input_demo.dart';
import '../demos/shape_tab_demo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('组件库'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildComponentList(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.widgets,
              size: 48,
              color: Colors.blue.shade600,
            ),
            const SizedBox(height: 16),
            const Text(
              'Flutter 组件库',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '收集和展示各种实用的Flutter组件',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentList(BuildContext context) {
    final components = [
      _ComponentItem(
        title: '图片轮播器',
        description: '支持自动播放、手动控制、多种指示器、缩放、预加载、错误重试等功能的图片轮播组件',
        icon: Icons.image,
        color: Colors.blue,
        demoPage: const CarouselDemo(),
      ),
      _ComponentItem(
        title: '轮播图缓存功能',
        description: '展示轮播图的图片缓存功能，包括内存缓存、磁盘缓存、预加载等特性',
        icon: Icons.cached,
        color: Colors.teal,
        demoPage: const CarouselCacheDemo(),
      ),
      _ComponentItem(
        title: '轮播图Hero动画',
        description: '展示轮播图的Hero动画效果，点击图片时平滑过渡到全屏查看',
        icon: Icons.animation,
        color: Colors.purple,
        demoPage: const CarouselHeroDemo(),
      ),
      _ComponentItem(
        title: 'Hero动画测试',
        description: '简单的Hero动画测试页面，用于验证Hero动画功能是否正常工作',
        icon: Icons.flip_camera_android,
        color: Colors.orange,
        demoPage: const HeroTestDemo(),
      ),
      _ComponentItem(
        title: '进度对话框',
        description: '通用进度对话框组件，支持外部控制进度和错误处理',
        icon: Icons.hourglass_empty,
        color: Colors.green,
        demoPage: const ProgressDemo(),
      ),
      _ComponentItem(
        title: '手机号输入框',
        description: '带格式化和验证的手机号输入组件',
        icon: Icons.phone,
        color: Colors.orange,
        demoPage: const PhoneInputDemo(),
      ),
      _ComponentItem(
        title: '形状标签组件',
        description: '自定义形状的标签组件',
        icon: Icons.label,
        color: Colors.purple,
        demoPage: const ShapeTabDemo(),
      ),
    ];

    return Column(
      children: components.map((component) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: component.color.withOpacity(0.2),
              child: Icon(
                component.icon,
                color: component.color,
              ),
            ),
            title: Text(
              component.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(component.description),
            trailing: component.demoPage != null
                ? Icon(Icons.arrow_forward_ios, color: component.color)
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '无演示',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
            onTap: component.demoPage != null
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => component.demoPage!,
                      ),
                    )
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _ComponentItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget? demoPage;

  _ComponentItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.demoPage,
  });
}
