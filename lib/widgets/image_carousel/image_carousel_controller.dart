import 'dart:async';
import 'package:flutter/material.dart';

class ImageCarouselController extends ChangeNotifier {
  Timer? _autoPlayTimer;
  int _currentIndex = 0;
  int _totalCount = 0;
  bool _isAutoPlaying = false;
  Duration _autoPlayInterval = const Duration(seconds: 3);

  // Getters
  int get currentIndex => _currentIndex;
  int get totalCount => _totalCount;
  bool get isAutoPlaying => _isAutoPlaying;

  /// 设置图片总数
  void setTotalCount(int count) {
    if (_totalCount != count) {
      _totalCount = count;
      Future.microtask(() {
        notifyListeners();
      });
    }
  }

  /// 更新当前页面索引
  void updateCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      Future.microtask(() {
        notifyListeners();
      });
    }
  }

  /// 设置当前索引
  void setCurrentIndex(int index) {
    if (index >= 0 && index < _totalCount && _currentIndex != index) {
      _currentIndex = index;
      Future.microtask(() {
        notifyListeners();
      });
    }
  }

  /// 下一页
  void nextPage() {
    if (_currentIndex < _totalCount - 1) {
      setCurrentIndex(_currentIndex + 1);
    } else {
      // 循环到第一页
      setCurrentIndex(0);
    }
  }

  /// 上一页
  void previousPage() {
    if (_currentIndex > 0) {
      setCurrentIndex(_currentIndex - 1);
    } else {
      // 循环到最后一页
      setCurrentIndex(_totalCount - 1);
    }
  }

  /// 跳转到指定索引
  void jumpToPage(int index) {
    setCurrentIndex(index);
  }

  /// 开始自动播放
  void startAutoPlay({Duration? interval}) {
    if (_totalCount <= 1) return;
    
    _isAutoPlaying = true;
    _autoPlayInterval = interval ?? _autoPlayInterval;
    
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(_autoPlayInterval, (timer) {
      nextPage();
    });
    
    Future.microtask(() {
      notifyListeners();
    });
  }

  /// 停止自动播放
  void stopAutoPlay() {
    _isAutoPlaying = false;
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    Future.microtask(() {
      notifyListeners();
    });
  }

  /// 切换自动播放状态
  void toggleAutoPlay({Duration? interval}) {
    if (_isAutoPlaying) {
      stopAutoPlay();
    } else {
      startAutoPlay(interval: interval);
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

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    super.dispose();
  }
} 