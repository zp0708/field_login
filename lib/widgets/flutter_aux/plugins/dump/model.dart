import 'dart:convert';

/// HttpStatus
enum HttpDumpStatus {
  /// requesting
  requesting,

  /// success
  success,

  /// error
  error,
}

/// HttpDumpRecord
class HttpDumpRecord {
  ///
  HttpDumpRecord(this.requestId, this.uri, this.method, this.requestTime, this.dumpStatus);

  ///
  final int requestId;

  ///
  final String uri;

  ///
  final String method;

  ///
  final DateTime requestTime;

  ///
  HttpDumpStatus dumpStatus;

  ///
  DateTime? finishTime;

  ///
  Map<String, dynamic>? requestHeader;

  ///
  Map<String, dynamic>? requestQuery;

  ///
  dynamic requestBody;

  ///
  int? httpCode;

  ///
  // String? responseBody;
  dynamic response;

  /// 后端排查用
  String? logId;

  ///
  String getStatusText() {
    switch (dumpStatus) {
      case HttpDumpStatus.requesting:
        return '请求中';
      case HttpDumpStatus.error:
        return '失败';
      case HttpDumpStatus.success:
        return '成功';
    }
  }

  ///
  int getCostTime() {
    if (finishTime == null) {
      return 0;
    }
    return finishTime!.millisecondsSinceEpoch - requestTime.millisecondsSinceEpoch;
  }

  String get getCURL {
    final StringBuffer cmd = StringBuffer('curl');

    // Method
    cmd.write(' -X $method');

    // URL
    cmd.write(' $uri');

    // Headers
    cmd.write(' ${_getCURLHeader()}');

    // Data (body)
    if (requestBody != null) {
      dynamic data = requestBody ?? '';
      if (data is Map) {
        data = json.encode(data);
      } else {
        data = data.toString();
      }
      cmd.write(' -d \'$data\'');
    }

    return cmd.toString();
  }

  String _getCURLHeader() {
    final StringBuffer sb = StringBuffer();
    requestHeader?.forEach((dynamic key, dynamic value) {
      sb.write(' -H \'$key: $value\'');
    });
    return sb.toString().trim();
  }
}
