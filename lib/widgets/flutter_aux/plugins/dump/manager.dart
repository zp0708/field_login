import 'package:flutter/foundation.dart';
import 'model.dart';

///
class DumpManager {
  static final List<HttpDumpRecord> _list = <HttpDumpRecord>[];
  static VoidCallback? _observer;

  ///
  static List<HttpDumpRecord> getRecordList() {
    return _list;
  }

  ///
  static void add(HttpDumpRecord record) {
    _list.add(record);
    if (_list.length > 110) {
      _list.removeRange(0, 10);
    }
    _notifyObserver();
  }

  ///
  static void update(int requestId, int httpCode, dynamic responseBody, String? logId) {
    for (var i = _list.length - 1; i >= 0; i--) {
      HttpDumpRecord record = _list[i];
      if (record.requestId == requestId) {
        record.logId = logId;
        record.httpCode = httpCode;
        record.dumpStatus = httpCode == -1 ? HttpDumpStatus.error : HttpDumpStatus.success;
        record.response = responseBody;
        record.finishTime = DateTime.now();
        break;
      }
    }
    _notifyObserver();
  }

  ///
  static void setObserver(VoidCallback? observer) {
    _observer = observer;
  }

  ///
  static void clear() {
    _list.clear();
    _notifyObserver();
  }

  static void _notifyObserver() {
    _observer?.call();
  }
}
