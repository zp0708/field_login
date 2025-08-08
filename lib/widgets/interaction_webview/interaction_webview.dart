import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// WebView 交互回调接口
class WebViewInteractionCallback {
  /// 收到来自 JavaScript 的消息
  final void Function(String type, dynamic data)? onJsMessage;

  /// WebView 加载状态变化
  final void Function(bool isLoading)? onLoadingChanged;

  /// WebView 错误
  final void Function(String error)? onError;

  /// WebView 准备就绪
  final void Function()? onReady;

  WebViewInteractionCallback({
    this.onJsMessage,
    this.onLoadingChanged,
    this.onError,
    this.onReady,
  });
}

/// WebView 交互控制器
class InteractionWebViewController {
  InAppWebViewController? _webViewController;
  bool _isWebViewReady = false;

  /// 检查 WebView 是否准备就绪
  bool get isReady => _isWebViewReady;

  /// 设置 WebView 控制器
  void setController(InAppWebViewController controller) {
    _webViewController = controller;
  }

  /// 设置 WebView 准备状态
  void setReady(bool ready) {
    _isWebViewReady = ready;
  }

  /// 向 WebView 发送消息
  Future<void> sendMessage(String type, dynamic data) async {
    if (!_isWebViewReady || _webViewController == null) {
      print('WebView 未准备就绪');
      return;
    }

    final encoded = jsonEncode(data);
    await _webViewController!.evaluateJavascript(source: '''
      if (typeof window.$type === 'function') {
        window.$type($encoded);
      } else {
        console.log('未找到函数: $type');
      }
    ''');
  }

  /// 调用 WebView 中的特定函数
  Future<void> callFunction(String functionName, List<dynamic> arguments) async {
    if (!_isWebViewReady || _webViewController == null) {
      print('WebView 未准备就绪');
      return;
    }

    final args = arguments.map((arg) => jsonEncode(arg)).join(', ');
    await _webViewController!.evaluateJavascript(source: '''
      if (typeof window.$functionName === 'function') {
        window.$functionName($args);
      } else {
        console.log('未找到函数: $functionName');
      }
    ''');
  }

  /// 重新加载 WebView
  Future<void> reload() async {
    await _webViewController?.reload();
  }

  /// 获取 WebView 控制器
  InAppWebViewController? get controller => _webViewController;
}

/// WebView 交互页面
///
/// 功能特性：
/// 1. 专注于 WebView 交互
/// 2. 提供外界调用接口
/// 3. 双向通信：Flutter <-> JavaScript
/// 4. 加载状态和错误处理
///
/// 使用方法：
/// 1. 通过 controller 调用交互方法
/// 2. 通过 callback 接收 JavaScript 消息
///
/// 技术实现：
/// - 使用 flutter_inappwebview 插件
/// - evaluateJavascript 实现 Flutter -> JS 通信
/// - window.flutter_inappwebview.callHandler 实现 JS -> Flutter 通信
class InteractionWebViewPage extends StatefulWidget {
  final InteractionWebViewController controller;
  final WebViewInteractionCallback? callback;
  final String htmlAssetPath;
  final Map<String, dynamic>? initialSettings;

  const InteractionWebViewPage({
    super.key,
    required this.controller,
    this.callback,
    this.htmlAssetPath = 'assets/webview/test_page.html',
    this.initialSettings,
  });

  @override
  State<InteractionWebViewPage> createState() => _InteractionWebViewPageState();
}

class _InteractionWebViewPageState extends State<InteractionWebViewPage> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initWebView();

    // 添加超时机制，防止无限加载
    Future.delayed(const Duration(seconds: 10), () {
      if (_isLoading && mounted) {
        print('WebView 加载超时，强制设置为完成状态');
        _updateLoadingState(false);
      }
    });
  }

  void _initWebView() {
    // WebView 初始化在 build 方法中进行
  }

  void _injectJavaScript() {
    widget.controller.sendMessage('init', {'timestamp': DateTime.now().toIso8601String()});
  }

  void _handleJsMessage(String type, dynamic data) {
    // 通知外界
    widget.callback?.onJsMessage?.call(type, data);

    // 默认处理
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('收到JS消息: $type -> $data')),
      );
    }
  }

  void _updateLoadingState(bool isLoading) {
    print('更新加载状态: $isLoading');
    setState(() {
      _isLoading = isLoading;
    });
    widget.callback?.onLoadingChanged?.call(isLoading);
  }

  void _handleError(String error) {
    setState(() {
      _errorMessage = error;
    });
    widget.callback?.onError?.call(error);
  }

  void _handleReady() {
    widget.controller.setReady(true);
    widget.callback?.onReady?.call();
    _injectJavaScript();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<String>(
          future: rootBundle.loadString(widget.htmlAssetPath),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              print('HTML 文件加载错误: ${snapshot.error}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('加载失败: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    Text('文件路径: ${widget.htmlAssetPath}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            }
            print('HTML 文件加载成功，长度: ${snapshot.data?.length}');
            return InAppWebView(
              initialData: InAppWebViewInitialData(
                data: snapshot.data!,
                mimeType: 'text/html',
                encoding: 'UTF-8',
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                allowsInlineMediaPlayback: true,
                mediaPlaybackRequiresUserGesture: false,
                useShouldOverrideUrlLoading: true,
                useOnLoadResource: true,
              ),
              onWebViewCreated: (controller) {
                print('WebView 控制器创建成功');
                widget.controller.setController(controller);

                // 添加 JavaScript 处理器
                controller.addJavaScriptHandler(
                  handlerName: 'AppBridge',
                  callback: (args) {
                    print('收到 JavaScript 回调: ${args[0]}');
                    try {
                      final Map<String, dynamic> data = jsonDecode(args[0]);
                      final type = data['type'];
                      final payload = data['data'];
                      _handleJsMessage(type, payload);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('收到JS消息: ${args[0]}')),
                        );
                      }
                    }
                  },
                );
              },
              onLoadStart: (controller, url) {
                print('WebView 开始加载: $url');
                _updateLoadingState(true);
                _errorMessage = null;
              },
              onLoadStop: (controller, url) {
                print('WebView 加载完成: $url');
                // 添加延迟确保内容完全加载
                Future.delayed(const Duration(milliseconds: 500), () {
                  _updateLoadingState(false);
                  _handleReady();
                });
              },
              onReceivedError: (controller, url, WebResourceError error) {
                print('WebView 加载错误: ${error.toString()}');
                _updateLoadingState(false);
                _handleError('加载失败: ${error.toString()}');
              },
              onConsoleMessage: (controller, consoleMessage) {
                print('WebView Console: ${consoleMessage.message}');
              },
              onLoadResource: (controller, resource) {
                print('WebView 加载资源: ${resource.url}');
              },
            );
          },
        ),
        if (_isLoading)
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在加载...'),
              ],
            ),
          ),
        if (_errorMessage != null)
          Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                        _isLoading = true;
                      });
                      widget.controller.reload();
                    },
                    child: const Text('重新加载'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
