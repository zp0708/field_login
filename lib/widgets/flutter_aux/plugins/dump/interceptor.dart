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

      record.requestHeader = _formatMap(options.headers);
      record.requestQuery = _formatMap(options.queryParameters);
      record.requestBody = '${options.data}';

      DumpManager.add(record);
    } catch (e) {
      // do nothing
    }
    handler.next(options);
  }

  static String _formatMap(Map<dynamic, dynamic> map) {
    final StringBuffer sb = StringBuffer();
    map.forEach((dynamic key, dynamic value) {
      sb.write('$key=$value');
      sb.write('\n');
    });
    return sb.toString().trim();
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      final int code = response.statusCode ?? -1;
      final String body = response.toString();
      DumpManager.update(response.requestOptions.hashCode, code, body);
    } catch (e) {
      // do nothing
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      final int code = err.response?.statusCode ?? -1;
      final String body = err.response?.toString() ?? '-1';
      DumpManager.update(err.requestOptions.hashCode, code, body);
    } catch (e) {
      // do nothing
    }

    handler.next(err);
  }
}
