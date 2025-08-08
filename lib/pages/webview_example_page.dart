import 'package:flutter/material.dart';
import '../widgets/interaction_webview/interaction_webview.dart';
import 'package:flutter/services.dart' show rootBundle;

/// WebView 交互示例页面
///
/// 展示如何使用 InteractionWebViewPage 进行 WebView 交互
class WebViewExamplePage extends StatefulWidget {
  const WebViewExamplePage({super.key});

  @override
  State<WebViewExamplePage> createState() => _WebViewExamplePageState();
}

class _WebViewExamplePageState extends State<WebViewExamplePage> {
  late InteractionWebViewController _webViewController;
  String _lastMessage = '';

  @override
  void initState() {
    super.initState();
    _webViewController = InteractionWebViewController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView 交互示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 控制面板
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '控制面板',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _webViewController.sendMessage('updateDesign', '红色+条纹格');
                        },
                        child: const Text('更新设计'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _webViewController.sendMessage('updateScene', '室内展厅');
                        },
                        child: const Text('更新场景'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _webViewController.callFunction('testDesignUpdate', []);
                        },
                        child: const Text('测试设计更新'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _webViewController.reload();
                        },
                        child: const Text('重新加载'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          print('WebView 准备状态: ${_webViewController.isReady}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('WebView 准备状态: ${_webViewController.isReady}'),
                            ),
                          );
                        },
                        child: const Text('检查状态'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final htmlContent = await rootBundle.loadString('assets/webview/test_page.html');
                            print('HTML 内容长度: ${htmlContent.length}');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('HTML 内容长度: ${htmlContent.length}'),
                              ),
                            );
                          } catch (e) {
                            print('加载 HTML 文件失败: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('加载 HTML 文件失败: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text('测试文件加载'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          print('强制隐藏加载状态');
                          setState(() {
                            // 强制隐藏加载状态用于测试
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('已尝试强制隐藏加载状态'),
                            ),
                          );
                        },
                        child: const Text('强制隐藏加载'),
                      ),
                    ),
                  ],
                ),
                if (_lastMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '最后消息: $_lastMessage',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // WebView 页面
          Expanded(
            child: InteractionWebViewPage(
              controller: _webViewController,
              htmlAssetPath: 'assets/webview/test_page.html',
              callback: WebViewInteractionCallback(
                onJsMessage: (type, data) {
                  setState(() {
                    _lastMessage = '$type: $data';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('收到JS消息: $type -> $data'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                onLoadingChanged: (isLoading) {
                  print('WebView 加载状态: $isLoading');
                },
                onError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('WebView 错误: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                onReady: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('WebView 准备就绪'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
