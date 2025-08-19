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
    _list.insert(0, record);
    if (_list.length > 100) {
      _list.removeLast();
    }
    _notifyObserver();
  }

  ///
  static void update(int requestId, int httpCode, String responseBody) {
    for (final HttpDumpRecord record in _list) {
      if (record.requestId == requestId) {
        record.httpCode = httpCode;
        record.dumpStatus = httpCode == -1 ? HttpDumpStatus.error : HttpDumpStatus.success;
        record.responseBody = responseBody;
        record.finishTime = DateTime.now();
        break;
      }
    }
    _notifyObserver();
  }

  ///
  static void setObserver(VoidCallback? observer) {
    _observer = _observer;
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
