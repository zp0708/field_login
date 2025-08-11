import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
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
            leftToolbarItems: _leftToolbarItems,
            onItemTap: (item) {
              _webViewController.sendMessage('updateDesign', item['name']);
            },
          ),
          Positioned(
            left: 300,
            top: 100,
            width: 200,
            height: 200,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                // color: Colors.white.withAlpha(100),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRect(
                child: BackdropFilter(
                  blendMode: BlendMode.src,
                  filter: ImageFilter.dilate(radiusX: 20, radiusY: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: 200,
                        height: 200,
                        color: Colors.white.withAlpha(100),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
