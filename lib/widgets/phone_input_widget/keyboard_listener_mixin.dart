import 'dart:ui';
import 'package:flutter/widgets.dart';

mixin KeyboardListenerMixin<T extends StatefulWidget> on State<T> {
  late final _KeyboardBindingObserver _keyboardBindingObserver;
  bool _isKeyboardVisible = false;
  double _keyboardHeight = 0.0;

  bool get isKeyboardVisible => _isKeyboardVisible;
  double get keyboardHeight => _keyboardHeight;

  @override
  void initState() {
    super.initState();
    _keyboardBindingObserver = _KeyboardBindingObserver(_handleKeyboardVisibilityChanged);
    WidgetsBinding.instance.addObserver(_keyboardBindingObserver);
    _keyboardBindingObserver.checkKeyboardVisibility(); // 初始化同步一次
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_keyboardBindingObserver);
    super.dispose();
  }

  void _handleKeyboardVisibilityChanged(bool visible, double bottomInset) {
    if (_isKeyboardVisible != visible || _keyboardHeight != bottomInset) {
      _isKeyboardVisible = visible;
      _keyboardHeight = bottomInset;
      onKeyboardVisibilityChanged(visible, bottomInset);
    }
  }

  /// ✅ 子类可 override：接收键盘是否显示以及键盘高度
  void onKeyboardVisibilityChanged(bool visible, double keyboardHeight) {}
}

class _KeyboardBindingObserver with WidgetsBindingObserver {
  final void Function(bool visible, double bottomInset) onChanged;

  _KeyboardBindingObserver(this.onChanged);

  @override
  void didChangeMetrics() {
    checkKeyboardVisibility();
  }

  void checkKeyboardVisibility() {
    final bottomInset = PlatformDispatcher.instance.views.first.viewInsets.bottom;
    final visible = bottomInset > 0.0;
    onChanged(visible, bottomInset);
  }
}
