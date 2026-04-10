// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:manicure/conf/env.dart';
import 'package:manicure/third/flutter_aux/plugins/dump/interceptor.dart';

class YoudaoTranslator {
  final String appKey;
  final String appSecret;
  final Dio dio = Dio()
    ..interceptors.addAll([
      DumpInterceptor(),
      if (kDebugMode && Env.isDev) LogInterceptor(
        requestBody: true, responseBody: true,
      ),
    ]);

  YoudaoTranslator({
    required this.appKey,
    required this.appSecret,
  });

  Future<String?> translate(String text) async {
    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final curtime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

    final signStr = appKey + truncate(text) + salt + curtime + appSecret;
    final sign = sha256.convert(utf8.encode(signStr)).toString();

    final data = {
      'q': text,
      'from': 'zh-CHS',
      'to': 'en',
      'appKey': appKey,
      'salt': salt,
      'sign': sign,
      'signType': 'v3',
      'curtime': curtime,
    };

    // user_id:1000095 staff_id: 1000018
    try {
      final res = await dio.post(
        'https://openapi.youdao.com/api',
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      if (res.statusCode == 200 && res.data['translation'] != null) {
        return res.data['translation'][0];
      }
    } catch (e) {
      debugPrint('翻译错误: $e');
    }
    return null;
  }

  /// 和有道官方保持一致的 truncate 实现
  String truncate(String s) {
    if (s.length <= 20) return s;
    return '${s.substring(0, 10)}${s.length}${s.substring(s.length - 10)}';
  }
}
