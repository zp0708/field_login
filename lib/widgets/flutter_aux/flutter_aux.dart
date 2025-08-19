import 'package:field_login/widgets/flutter_aux/pluggable.dart';
import 'package:field_login/widgets/flutter_aux/plugins/entries.dart';
import 'package:field_login/widgets/flutter_aux/ui/plugin_wrapper.dart';
import 'package:flutter/material.dart';

/// Overlay 管理器，负责管理 overlay 的弹出和移除
class OverlayManager {
  static OverlayEntry? _currentOverlay;
  static Offset _currentPosition = const Offset(50, 100);
  static List<Pluggable> _plugins = [];

  static List<Pluggable> get plugins => _plugins;

  /// 显示 overlay
  static void showOverlay(
    BuildContext context, {
    required List<Pluggable> plugins,
  }) {
    _plugins = plugins;
    // 显示入口
    showEntries(context);
  }

  /// 显示入口
  static void showEntries(BuildContext context) {
    _plugins = plugins;
    // 显示入口
    showPlugin(context, Entries());
  }

  static void showPlugin(BuildContext context, Pluggable plugin) {
    // 移除当前 overlay
    removeOverlay();
    final overlay = Overlay.of(context);
    _currentPosition = plugin.position;
    _currentOverlay = getOverlay(context, plugin);
    overlay.insert(_currentOverlay!);
  }

  static OverlayEntry getOverlay(BuildContext context, Pluggable plugin) {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          top: _currentPosition.dy,
          left: _currentPosition.dx,
          child: Material(
            color: Colors.transparent,
            child: PluginWrapper(
              plugin: plugin,
              onClose: () => plugin.name == 'entries' ? removeOverlay() : showEntries(context),
              child: plugin.build(context),
            ),
          ),
        );
      },
    );
  }

  /// 更新 overlay 位置
  static void updatePosition(Offset newPosition) {
    _currentPosition = newPosition;
    _currentOverlay?.markNeedsBuild();
  }

  /// 移除当前 overlay
  static void removeOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// 检查是否有 overlay 正在显示
  static bool get isOverlayVisible => _currentOverlay != null;
}
