import 'package:field_login/pages/widgets/left_tools_bar.dart';
import 'package:field_login/widgets/interaction_webview/interaction_webview.dart';
import 'package:flutter/material.dart';

class ModelPreviewPage extends StatefulWidget {
  const ModelPreviewPage({super.key});

  @override
  State<ModelPreviewPage> createState() => _ModelPreviewPageState();
}

class _ModelPreviewPageState extends State<ModelPreviewPage> {
  late InteractionWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = InteractionWebViewController();
  }

  // 左侧工具栏数据
  final List<Map<String, dynamic>> _leftToolbarItems = [
    {'id': '1', 'name': '红色+条纹格', 'selected': true, 'color': const Color(0xFFE53935)},
    {'id': '2', 'name': '蓝色+粗猫眼', 'selected': false, 'color': const Color(0xFF1E88E5)},
    {'id': '3', 'name': '紫色+磨砂', 'selected': false, 'color': const Color(0xFF8E24AA)},
    {'id': '4', 'name': '彩色+粗猫眼', 'selected': false, 'color': const Color(0xFF43A047)},
    {'id': '5', 'name': '粉色+亮片', 'selected': false, 'color': const Color(0xFFF06292)},
    {'id': '6', 'name': '黑色+金属', 'selected': false, 'color': const Color(0xFF424242)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D 模型预览'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: 0,
            child: InteractionWebViewPage(
              htmlAssetPath: 'assets/webview/test_page.html',
              controller: _webViewController,
            ),
          ),
          LeftToolsBar(
            leftToolbarItems: _leftToolbarItems,
            onItemTap: (item) {
              _webViewController.sendMessage('updateDesign', item['name']);
            },
          ),
        ],
      ),
    );
  }
}
