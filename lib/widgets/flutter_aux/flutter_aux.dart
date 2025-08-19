import 'package:field_login/widgets/flutter_aux/pluggable.dart';
import 'package:field_login/widgets/flutter_aux/plugins/entries.dart';
import 'package:field_login/widgets/flutter_aux/ui/plugin_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overlay 管理器，负责管理 overlay 的弹出和移除
class OverlayManager {
  static OverlayEntry? _currentOverlay;
  static Offset _currentPosition = const Offset(100, 100); // 默认位置
  static List<Pluggable> _plugins = [];
  static String? _currentPluginName;

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

    // 设置当前插件名称
    _currentPluginName = plugin.name;

    // 先使用默认位置显示，然后异步恢复保存的位置
    _currentPosition = Offset(100, 100);

    final overlay = Overlay.of(context);
    _currentOverlay = getOverlay(context, plugin);
    overlay.insert(_currentOverlay!);

    // 异步恢复保存的位置
    _restoreSavedPosition(plugin.name, context);
  }

  static void _restoreSavedPosition(String pluginName, BuildContext context) async {
    try {
      final savedPosition = await _getSavedPosition(pluginName);
      if (savedPosition != null && _currentOverlay != null) {
        _currentPosition = savedPosition;
        _currentOverlay!.markNeedsBuild();
      }
    } catch (e) {
      // 忽略错误
    }
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
              position: _currentPosition,
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
    // 保存当前位置
    saveCurrentPosition();

    _currentOverlay?.remove();
    _currentOverlay = null;
    _currentPluginName = null;
  }

  /// 检查是否有 overlay 正在显示
  static bool get isOverlayVisible => _currentOverlay != null;

  /// 获取保存的位置
  static Future<Offset?> _getSavedPosition(String pluginName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final x = prefs.getDouble('overlay_position_${pluginName}_x');
      final y = prefs.getDouble('overlay_position_${pluginName}_y');
      if (x != null && y != null) {
        return Offset(x, y);
      }
    } catch (e) {
      // 忽略错误，返回 null
    }
    return null;
  }

  /// 保存当前位置
  static Future<void> _savePosition(String pluginName, Offset position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('overlay_position_${pluginName}_x', position.dx);
      await prefs.setDouble('overlay_position_${pluginName}_y', position.dy);
    } catch (e) {
      // 忽略错误
    }
  }

  /// 保存当前插件的位置
  static Future<void> saveCurrentPosition() async {
    if (_currentPluginName != null) {
      await _savePosition(_currentPluginName!, _currentPosition);
    }
  }
}
