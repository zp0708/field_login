import 'dart:async';
import 'progress_dialog.dart';

class ProgressController {
  final StreamController<Map<String, dynamic>> _statusController = StreamController<Map<String, dynamic>>.broadcast();

  ProgressStatus _status = ProgressStatus.loading;
  double _progress = 0.0;
  String? _errorMessage;

  Stream<Map<String, dynamic>> get statusStream => _statusController.stream;
  ProgressStatus get status => _status;
  double get progress => _progress;
  String? get errorMessage => _errorMessage;

  // 更新进度
  void updateProgress(double progress) {
    _progress = progress.clamp(0.0, 1.0);
    _notifyUpdate();
  }

  // 设置状态
  void setStatus(ProgressStatus status) {
    _status = status;
    _notifyUpdate();
  }

  // 设置错误信息
  void setError(String errorMessage) {
    _status = ProgressStatus.error;
    _errorMessage = errorMessage;
    _notifyUpdate();
  }

  // 完成
  void finish() {
    _status = ProgressStatus.finished;
    _progress = 1.0;
    _notifyUpdate();
  }

  // 通知更新
  void _notifyUpdate() {
    _statusController.add({
      'status': _status,
      'progress': _progress,
      'errorMessage': _errorMessage,
    });
  }

  // 重置状态
  void reset() {
    _status = ProgressStatus.loading;
    _progress = 0.0;
    _errorMessage = null;
  }

  // 释放资源
  void dispose() {
    _statusController.close();
  }
}
