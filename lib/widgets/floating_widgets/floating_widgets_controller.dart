import 'package:flutter/material.dart';

class FloatingWidgetsController extends ChangeNotifier {
  bool _isAnimating = true;
  bool _autoPauseEnabled = true; // 是否允许自动暂停（路由感知）

  bool get isAnimating => _isAnimating;
  bool get autoPauseEnabled => _autoPauseEnabled;

  void play() {
    if (_isAnimating) return;
    _isAnimating = true;
    notifyListeners();
  }

  void pause() {
    if (!_isAnimating) return;
    _isAnimating = false;
    notifyListeners();
  }

  void toggle() {
    if (_isAnimating) {
      pause();
    } else {
      play();
    }
  }

  void setAutoPauseEnabled(bool enabled) {
    if (_autoPauseEnabled == enabled) return;
    _autoPauseEnabled = enabled;
    notifyListeners();
  }
}
