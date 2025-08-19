import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'flutter_aux.dart';
import 'plugins/proxy_settings.dart';
import 'plugins/dump/interceptor.dart';
import 'plugins/dump/network_data.dart';

final dio = Dio()..interceptors.add(DumpInterceptor());

class OverlayDemo extends StatelessWidget {
  const OverlayDemo({super.key});

  void _showFunctionGrid(BuildContext context) {
    OverlayManager.showOverlay(context, plugins: [
      ProxySettings(),
      NetworkData(),
    ]);
  }

  void _performNetworkData(BuildContext context) {
    dio.post(
      'http://shop.moonbii.net/shop/order/get_sku_info/',
      data: {
        'product_id': 1053,
        'params': [101, 104, 140]
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'token':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTYxNzQ0MzMsIm9yaWdfaWF0IjoxNzU1NTY5NjMzLCJ1c2VyX2luZm8iOiJ7XCJVc2VySWRcIjoxMDAwMDAyLFwiUm9sZVwiOjEsXCJTdG9yZUlkXCI6MTAwMDF9In0.fXL1pGTbp9XBCZ9tNzpMZfL6-EF-hyfOkQS2zH0hqBk'
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Overlay 示例"),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 长按按钮
              GestureDetector(
                onLongPress: () => _showFunctionGrid(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "长按显示功能入口",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _performNetworkData(context),
                child: const Text('抓包测试'),
              ),
              const SizedBox(height: 24),
              // 说明文字
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '长按上方按钮可以查看所有可用的功能入口',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
