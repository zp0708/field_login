import 'package:field_login/widgets/flutter_aux/pluggable.dart';
import 'package:field_login/widgets/flutter_aux/plugins/entries.dart';
import 'package:field_login/widgets/flutter_aux/ui/plugin_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overlay 管理器，负责管理 overlay 的弹出和移除
class OverlayManager {
  static OverlayEntry? _currentOverlay;
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

  static void showPlugin(BuildContext context, Pluggable plugin) async {
    // 移除当前 overlay
    removeOverlay();

    // 恢复保存的位置
    final position = await _getSavedPosition(plugin.name) ?? Offset(100, 100);
    // 恢复保存的大小
    final size = await _getSavedSize(plugin.name) ?? plugin.size;

    // 异步恢复保存的位置和大小
    if (context.mounted) {
      final overlay = Overlay.of(context);
      _currentOverlay = getOverlay(context, plugin, position, size);
      overlay.insert(_currentOverlay!);
    }
  }

  static OverlayEntry getOverlay(BuildContext context, Pluggable plugin, Offset position, Size size) {
    return OverlayEntry(
      builder: (context) {
        return PluginWrapper(
          plugin: plugin,
          position: position,
          size: size,
          onClose: () => plugin.name == 'entries' ? removeOverlay() : showEntries(context),
          child: plugin.build(context),
        );
      },
    );
  }

  /// 移除当前 overlay
  static void removeOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
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
  static Future<void> savePosition(String pluginName, Offset position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('overlay_position_${pluginName}_x', position.dx);
      await prefs.setDouble('overlay_position_${pluginName}_y', position.dy);
    } catch (e) {
      // 忽略错误
    }
  }

  /// 获取保存的大小
  static Future<Size?> _getSavedSize(String pluginName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final width = prefs.getDouble('overlay_size_${pluginName}_width');
      final height = prefs.getDouble('overlay_size_${pluginName}_height');
      if (width != null && height != null) {
        return Size(width, height);
      }
    } catch (e) {
      // 忽略错误，返回 null
    }
    return null;
  }

  /// 保存大小
  static Future<void> saveSize(String pluginName, Size size) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('overlay_size_${pluginName}_width', size.width);
      await prefs.setDouble('overlay_size_${pluginName}_height', size.height);
    } catch (e) {
      // 忽略错误
    }
  }
}
