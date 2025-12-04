import 'package:flutter/material.dart';
import './floating_widgets_controller.dart';

class FloatingWidgetsAware extends StatefulWidget {
  final FloatingWidgetsController controller;
  final Widget child;
  final RouteObserver<PageRoute<dynamic>>? routeObserver;

  const FloatingWidgetsAware({
    super.key,
    required this.controller,
    required this.child,
    this.routeObserver,
  });

  @override
  State<FloatingWidgetsAware> createState() => _FloatingWidgetsAwareState();
}

class _FloatingWidgetsAwareState extends State<FloatingWidgetsAware> with WidgetsBindingObserver, RouteAware {
  bool? _wasAnimatingBeforePause; // 记录路由暂停前的动画状态
  RouteObserver<PageRoute<dynamic>>? _routeObserver;
  bool _usingRouteAware = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 如果提供了 observer，但在 didChangeDependencies 时拿不到 route，延后一次尝试
    if (widget.routeObserver != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_usingRouteAware) {
          final ModalRoute<dynamic>? route = ModalRoute.of(context);
          if (route is PageRoute<dynamic>) {
            widget.routeObserver!.subscribe(this, route);
            _routeObserver = widget.routeObserver;
            _usingRouteAware = true;
          }
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 如果提供了 routeObserver，使用 RouteAware
    if (widget.routeObserver != null && !_usingRouteAware) {
      _routeObserver = widget.routeObserver;
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route is PageRoute<dynamic>) {
        _routeObserver!.subscribe(this, route);
        _usingRouteAware = true;
      }
    } else if (!_usingRouteAware) {
      // 如果没有提供 routeObserver，使用 ModalRoute 检查
      _checkRouteVisibility();
    }
  }

  void _checkRouteVisibility() {
    if (!widget.controller.autoPauseEnabled) return;

    final bool isRouteActive = ModalRoute.of(context)?.isCurrent ?? true;
    if (!isRouteActive) {
      _pauseIfRouteInactive();
    } else {
      _resumeIfRouteActive();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.controller.autoPauseEnabled) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _pauseIfRouteInactive();
    } else if (state == AppLifecycleState.resumed) {
      _resumeIfRouteActive();
    }
  }

  // RouteAware 生命周期方法（仅在提供了 routeObserver 时使用）

  @override
  void didPushNext() {
    // 从当前路由 push 到下一个路由时，暂停动画
    if (widget.controller.autoPauseEnabled) {
      _pauseIfRouteInactive();
    }
  }

  @override
  void didPopNext() {
    // 从下一个路由 pop 回当前路由时，恢复动画
    if (widget.controller.autoPauseEnabled) {
      _resumeIfRouteActive();
    }
  }

  @override
  void didPush() {
    // 当前路由被 push 时（首次进入），不需要特殊处理
    print('didPush');
  }

  @override
  void didPop() {
    // 当前路由被 pop 时，不需要特殊处理
    print('didPop');
  }

  void _pauseIfRouteInactive() {
    // 路由不活跃时，记录当前状态并暂停动画
    if (widget.controller.isAnimating) {
      _wasAnimatingBeforePause = true;
      _scheduleController(() => widget.controller.pause());
    } else {
      _wasAnimatingBeforePause = false;
    }
  }

  void _resumeIfRouteActive() {
    // 路由活跃时，恢复之前的播放状态
    if (_wasAnimatingBeforePause == true) {
      _scheduleController(() => widget.controller.play());
      _wasAnimatingBeforePause = null;
    }
  }

  void _scheduleController(VoidCallback action) {
    // 避免在 build/路由构建过程中直接触发重建，延迟到本帧结束
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      action();
    });
  }

  @override
  void dispose() {
    // 取消订阅 RouteObserver
    if (_usingRouteAware && _routeObserver != null) {
      _routeObserver!.unsubscribe(this);
    }

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
