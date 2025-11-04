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
  String? requestHeader;

  String? cURLHeader;

  ///
  String? requestQuery;

  ///
  String? requestBody;

  ///
  int? httpCode;

  ///
  String? responseBody;

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
}
