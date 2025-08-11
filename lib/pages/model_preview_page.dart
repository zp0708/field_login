import 'package:field_login/pages/widgets/toolbar_item.dart';
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
  final List<ToolbarItem> _leftToolbarItems = [
    ToolbarItem(id: '1', name: '红色+条纹格', selected: true, url: 'https://picsum.photos/280/280?random=1'),
    ToolbarItem(id: '2', name: '蓝色+粗猫眼', selected: false, url: 'https://picsum.photos/280/280?random=2'),
    ToolbarItem(id: '3', name: '紫色+磨砂', selected: false, url: 'https://picsum.photos/280/280?random=3'),
    // ToolbarItem(id: '4', name: '彩色+粗猫眼', selected: false, url: 'https://picsum.photos/280/280?random=4'),
    // ToolbarItem(id: '5', name: '粉色+亮片', selected: false, url: 'https://picsum.photos/280/280?random=5'),
    // ToolbarItem(id: '6', name: '黑色+金属', selected: false, url: 'https://picsum.photos/280/280?random=6'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            right: 0,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          InteractionWebViewPage(
            file: 'assets/webview/test_page.html',
            controller: _webViewController,
          ),
          LeftToolsBar(
            items: _leftToolbarItems,
            onItemTap: (item) {
              _webViewController.sendMessage('updateDesign', item.name);
            },
          ),
        ],
      ),
    );
  }
}
