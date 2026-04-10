import 'package:dio/dio.dart';
import 'model.dart';

import 'manager.dart';

/// DumpInterceptor
class DumpInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final HttpDumpRecord record = HttpDumpRecord(
        options.hashCode,
        options.uri.toString(),
        options.method,
        DateTime.now(),
        HttpDumpStatus.requesting,
      );

      record.requestHeader = options.headers;
      record.requestQuery = options.queryParameters;
      record.requestBody = options.data is Map ? options.data : options.data.toString();
      DumpManager.add(record);
    } catch (e) {
      // do nothing
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      final int code = response.statusCode ?? -1;
      dynamic body = response.data;
      // 图片上传时只返回一个空字符串
      if (body is String && body.isEmpty) {
        body = {
          'statusCode': response.statusCode,
          'statusMessage': response.statusMessage,
        };
      }
      final String? logId = response.headers['log_id']?.first;
      DumpManager.update(response.requestOptions.hashCode, code, body, logId);
    } catch (e) {
      // do nothing
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      final int code = err.response?.statusCode ?? -1;
      final dynamic body = err.response?.data ?? err.toString();
      DumpManager.update(err.requestOptions.hashCode, code, body, '');
    } catch (e) {
      // do nothing
    }

    handler.next(err);
  }
}
