import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

const int maxLine = 1000;

class ConsoleItem {
  final DateTime dateTime;
  final String message;
  const ConsoleItem(this.dateTime, this.message);
}

class ConsoleManager {
  static final Queue<ConsoleItem> _logData = Queue();
  // ignore: close_sinks
  static StreamController? _logStreamController;

  static Queue<ConsoleItem> get logData => _logData;

  static StreamController? get streamController => _getLogStreamController();

  static DebugPrintCallback? _originalDebugPrint;

  static StreamController? _getLogStreamController() {
    if (_logStreamController == null) {
      _logStreamController = StreamController.broadcast();
      var transformer = StreamTransformer<dynamic, ConsoleItem>.fromHandlers(handleData: (str, sink) {
        final now = DateTime.now();
        if (str is String) {
          sink.add(ConsoleItem(now, str));
        } else {
          sink.add(ConsoleItem(now, str.toString()));
        }
      });

      _logStreamController!.stream.transform(transformer).listen((value) {
        if (_logData.length < maxLine) {
          _logData.addFirst(value);
        } else {
          _logData.removeLast();
        }
      });
    }
    return _logStreamController;
  }

  static redirectDebugPrint() {
    if (_originalDebugPrint != null) return;
    _originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      ConsoleManager.streamController!.sink.add(message);
      if (_originalDebugPrint != null) {
        _originalDebugPrint!(message, wrapWidth: wrapWidth);
      }
    };
  }

  static clearLog() {
    logData.clear();
    _logStreamController!.add('UME CONSOLE == ClearLog');
  }

  @visibleForTesting
  static clearRedirect() {
    debugPrint = _originalDebugPrint!;
    _originalDebugPrint = null;
  }
}
