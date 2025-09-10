import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Timer state for countdown functionality
class TimerState {
  final int remainingSeconds;
  final bool isActive;
  final bool hasExpired;

  const TimerState({
    required this.remainingSeconds,
    required this.isActive,
    required this.hasExpired,
  });

  TimerState copyWith({
    int? remainingSeconds,
    bool? isActive,
    bool? hasExpired,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isActive: isActive ?? this.isActive,
      hasExpired: hasExpired ?? this.hasExpired,
    );
  }

  String get formattedTime {
    if (remainingSeconds <= 0) return '0秒';

    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    if (minutes > 0) {
      return '$minutes分$seconds秒';
    } else {
      return '$seconds秒';
    }
  }
}

/// Timer notifier for managing countdown state
class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  final int _initialSeconds;
  final VoidCallback? onExpired;

  TimerNotifier({
    required int initialSeconds,
    this.onExpired,
  })  : _initialSeconds = initialSeconds,
        super(TimerState(
          remainingSeconds: initialSeconds,
          isActive: true,
          hasExpired: false,
        )) {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds <= 0) {
        _timer?.cancel();
        state = state.copyWith(
          remainingSeconds: 0,
          isActive: false,
          hasExpired: true,
        );

        // 触发过期回调
        onExpired?.call();
        return;
      }

      state = state.copyWith(
        remainingSeconds: state.remainingSeconds - 1,
      );
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isActive: false);
  }

  void resume() {
    if (!state.hasExpired && state.remainingSeconds > 0) {
      state = state.copyWith(isActive: true);
      _startTimer();
    }
  }

  void reset() {
    _timer?.cancel();
    state = TimerState(
      remainingSeconds: _initialSeconds,
      isActive: true,
      hasExpired: false,
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider factory for creating timer instances
final timerProviderFamily =
    StateNotifierProvider.family<TimerNotifier, TimerState, ({int seconds, VoidCallback? onExpired})>(
  (ref, params) {
    return TimerNotifier(
      initialSeconds: params.seconds,
      onExpired: params.onExpired,
    );
  },
);
