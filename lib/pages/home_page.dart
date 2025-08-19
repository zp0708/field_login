import 'package:field_login/demos/carousel_demo.dart';
import 'package:field_login/demos/websocket_demo.dart';
import 'package:field_login/demos/double_tap_zoom_demo.dart';
import 'package:field_login/pages/scroll_to_index.dart';
import 'package:field_login/demos/overlay_demo.dart';
import 'package:field_login/widgets/semi_circle_scroll/rotating_menu.dart';
import 'package:flutter/material.dart';
import '../demos/progress_demo.dart';
import '../demos/phone_input_demo.dart';
import '../demos/shape_tab_demo.dart';
import '../widgets/model_preview/webview_example_page.dart';
import '../widgets/model_preview/model_preview_page.dart';
import '../demos/progress_timeline_demo.dart';

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
        title: '开发工具浮窗',
        description: '开发工具浮窗，支持拖动和关闭',
        icon: Icons.toll_outlined,
        color: Colors.blue,
        demoPage: OverlayDemo(),
      ),
      _ComponentItem(
        title: '滚动列表页面',
        description: '具有特殊滚动行为的列表页面，工具条跟随滚动，支持滚动到指定位置',
        icon: Icons.list,
        color: Colors.blue,
        demoPage: const SliverGridEasyRefreshScrollDemo(),
      ),
      _ComponentItem(
        title: '双击缩放演示',
        description: '专门演示图片轮播器双击缩放功能的页面，包含详细的功能说明和配置选项',
        icon: Icons.zoom_in,
        color: Colors.indigo,
        demoPage: const DoubleTapZoomDemo(),
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
        title: '进度时间线',
        description: '展示进度和时间线的组件',
        icon: Icons.timeline,
        color: Colors.indigo,
        demoPage: const ProgressTimelineDemo(),
      ),
      _ComponentItem(
        title: '形状标签组件',
        description: '自定义形状的标签组件',
        icon: Icons.label,
        color: Colors.purple,
        demoPage: const ShapeTabDemo(),
      ),
      _ComponentItem(
        title: '模型预览',
        description: '查看 3d 模块预览',
        icon: Icons.web_asset,
        color: Colors.blue,
        builder: (ctx) => const ModelPreviewPage(),
      ),
      _ComponentItem(
        title: 'WebView 交互示例',
        description: '封装的 WebView 交互组件，提供外界调用接口和回调机制',
        icon: Icons.web_asset,
        color: Colors.blue,
        builder: (ctx) => const WebViewExamplePage(),
      ),
      _ComponentItem(
        title: '右侧半透明半圆',
        description: '放在屏幕右侧中央的半透明半圆组件，支持自定义样式和内容',
        icon: Icons.circle,
        color: Colors.teal,
        demoPage: const LeftSemiCircleMenuDemo(),
      ),
      _ComponentItem(
        title: '圆形菜单组件',
        description: '按钮均匀分布在圆内的圆形菜单组件',
        icon: Icons.menu,
        color: Colors.pink,
        demoPage: const LeftSemiCircleMenuDemo(),
      ),
      _ComponentItem(
        title: 'Websocket',
        description: '按钮均匀分布在圆内的圆形菜单组件',
        icon: Icons.menu,
        color: Colors.pink,
        demoPage: const WebsocketDemo(),
      ),
    ];

    return Column(
      children: components.map((component) {
        final hasRoute = component.demoPage != null || component.builder != null;
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color.fromRGBO(
                component.color.red,
                component.color.green,
                component.color.blue,
                0.2,
              ),
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
            trailing: hasRoute
                ? Icon(Icons.arrow_forward_ios, color: component.color)
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(158, 158, 158, 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '无演示',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
            onTap: hasRoute
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            component.builder != null ? component.builder!(context) : component.demoPage!,
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
  final WidgetBuilder? builder;

  _ComponentItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.demoPage,
    this.builder,
  });
}
