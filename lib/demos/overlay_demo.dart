import 'package:dio/dio.dart';
import 'package:field_login/widgets/flutter_aux/flutter_aux.dart';
import 'package:field_login/widgets/flutter_aux/plugins/dump/interceptor.dart';
import 'package:field_login/widgets/flutter_aux/plugins/proxy_settings.dart';
import 'package:flutter/material.dart';

final dio = Dio()..interceptors.add(DumpInterceptor());

class OverlayDemo extends StatefulWidget {
  const OverlayDemo({super.key});

  @override
  State<OverlayDemo> createState() => _OverlayDemoState();
}

class _OverlayDemoState extends State<OverlayDemo> {
  String _proxy = '';

  @override
  void initState() {
    super.initState();
    _getProxy();
  }

  void _getProxy() async {
    _proxy = await ProxySettings.getProxy() ?? '未设置代理';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MaterialApp(
        home: Scaffold(
          body: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onLongPress: () => FlutterAux.show(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: Text('长按'),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => dio.get('http://124.220.49.230/api/time/getday.php'),
                  child: Text('抓包测试'),
                ),
                SizedBox(height: 20),
                Text(_proxy),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => debugPrint('测试控制台'),
                  child: Text('控制台打印'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
