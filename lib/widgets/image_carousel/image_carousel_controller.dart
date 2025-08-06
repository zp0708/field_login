import 'dart:async';
import 'package:flutter/material.dart';

class ImageCarouselController extends ChangeNotifier {
  Timer? _autoPlayTimer;
  int _currentIndex = 0;
  int _totalCount = 0;
  bool _isAutoPlaying = false;
  bool _isPaused = false;
  Duration _autoPlayInterval = const Duration(seconds: 3);
  DateTime? _lastUserInteraction;
  Duration _pauseAfterInteraction = const Duration(seconds: 5);

  // Getters
  int get currentIndex => _currentIndex;
  int get totalCount => _totalCount;
  bool get isAutoPlaying => _isAutoPlaying;
  bool get isPaused => _isPaused;
  Duration get autoPlayInterval => _autoPlayInterval;
  DateTime? get lastUserInteraction => _lastUserInteraction;

  /// 设置图片总数
  void setTotalCount(int count) {
    if (_totalCount != count) {
      _totalCount = count;
      // 立即通知，不使用 microtask 延迟
      notifyListeners();
    }
  }

  /// 更新当前页面索引
  void updateCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      _recordUserInteraction();
      // 立即通知，不使用 microtask 延迟
      notifyListeners();
    }
  }

  /// 设置当前索引
  void setCurrentIndex(int index) {
    if (index >= 0 && index < _totalCount && _currentIndex != index) {
      _currentIndex = index;
      _recordUserInteraction();
      // 立即通知，不使用 microtask 延迟
      notifyListeners();
    }
  }

  /// 下一页
  void nextPage() {
    if (_totalCount > 0) {
      setCurrentIndex((_currentIndex + 1) % _totalCount);
    }
  }

  /// 上一页
  void previousPage() {
    if (_totalCount > 0) {
      setCurrentIndex((_currentIndex - 1 + _totalCount) % _totalCount);
    }
  }

  /// 跳转到指定索引
  void jumpToPage(int index) {
    setCurrentIndex(index);
  }

  /// 记录用户交互
  void _recordUserInteraction() {
    _lastUserInteraction = DateTime.now();
    if (_isAutoPlaying && _isPaused) {
      // 用户交互后，延迟恢复自动播放
      Timer(_pauseAfterInteraction, () {
        if (_isAutoPlaying && _isPaused) {
          resumeAutoPlay();
        }
      });
    }
  }

  /// 开始自动播放
  void startAutoPlay({Duration? interval}) {
    if (_totalCount <= 1) return;

    _isAutoPlaying = true;
    _isPaused = false;
    _autoPlayInterval = interval ?? _autoPlayInterval;

    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(_autoPlayInterval, (timer) {
      if (!_isPaused) {
        nextPage();
      }
    });

    notifyListeners();
  }

  /// 停止自动播放
  void stopAutoPlay() {
    _isAutoPlaying = false;
    _isPaused = false;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    notifyListeners();
  }

  /// 暂停自动播放
  void pauseAutoPlay() {
    if (_isAutoPlaying && !_isPaused) {
      _isPaused = true;
      notifyListeners();
    }
  }

  /// 恢复自动播放
  void resumeAutoPlay() {
    if (_isAutoPlaying && _isPaused) {
      _isPaused = false;
      notifyListeners();
    }
  }

  /// 切换自动播放状态
  void toggleAutoPlay({Duration? interval}) {
    if (_isAutoPlaying) {
      stopAutoPlay();
    } else {
      startAutoPlay(interval: interval);
    }
  }

  /// 切换暂停状态
  void togglePause() {
    if (_isAutoPlaying) {
      if (_isPaused) {
        resumeAutoPlay();
      } else {
        pauseAutoPlay();
      }
    }
  }

  /// 设置自动播放间隔
  void setAutoPlayInterval(Duration interval) {
    _autoPlayInterval = interval;
    if (_isAutoPlaying) {
      stopAutoPlay();
      startAutoPlay(interval: interval);
    }
  }

  /// 设置交互后暂停时间
  void setPauseAfterInteraction(Duration duration) {
    _pauseAfterInteraction = duration;
  }

  /// 获取状态信息
  Map<String, dynamic> getStatus() {
    return {
      'currentIndex': _currentIndex,
      'totalCount': _totalCount,
      'isAutoPlaying': _isAutoPlaying,
      'isPaused': _isPaused,
      'autoPlayInterval': _autoPlayInterval.inMilliseconds,
      'lastUserInteraction': _lastUserInteraction?.millisecondsSinceEpoch,
      'progress': _totalCount > 0 ? (_currentIndex + 1) / _totalCount : 0.0,
    };
  }

  /// 重置控制器状态
  void reset() {
    _currentIndex = 0;
    _isAutoPlaying = false;
    _isPaused = false;
    _lastUserInteraction = null;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    super.dispose();
  }
}
