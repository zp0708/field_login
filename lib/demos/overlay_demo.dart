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
                  onTap: () => FlutterAux.show(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(1, 33, 34, 35),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: Text('点击'),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => dio.get(
                      'https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&hourly=temperature_2m,weather_code&past_days=5'),
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
