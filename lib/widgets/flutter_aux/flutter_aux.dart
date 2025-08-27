import 'plugins/console/console_plugin.dart';
import 'plugins/device_info.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'plugin_wrapper.dart';
import 'plugins/pluggable.dart';
import 'plugins/entries.dart';
import 'plugins/proxy_settings.dart';
import 'plugins/dump/network_data.dart';
import 'plugins/widget_info_inspector.dart';
import 'plugins/align_ruler.dart';
import 'plugins/widget_detail_inspector/widget_detail_inspector.dart';

/// Overlay 管理器，负责管理 overlay 的弹出和移除
class FlutterAux {
  static OverlayEntry? _currentOverlay;
  static List<Pluggable> _plugins = [];
  static ValueChanged<String>? _onMessage;
  static List<Pluggable> get plugins => _plugins;
  static BuildContext? _context;

  static BuildContext? get context => _context;

  /// 显示 overlay
  static void show(
    BuildContext context, {
    List<Pluggable>? plugins,
    ValueChanged<String>? onMessage,
  }) {
    _context = context;
    _onMessage = onMessage;
    _plugins = plugins ??
        [
          ProxySettings(),
          NetworkData(),
          DeviceInfo(),
          ConsolePlugin(),
          WidgetInfoInspector(),
          WidgetDetailInspector(),
          AlignRulerPlugin(),
        ];
    // 显示入口
    showEntries();
  }

  /// 显示入口
  static void showEntries() {
    _plugins = plugins;
    // 显示入口
    showPlugin(_context!, Entries());
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

  static OverlayEntry getOverlay(
    BuildContext context,
    Pluggable plugin,
    Offset position,
    Size size,
  ) {
    final bool isEntries = plugin is Entries;
    return OverlayEntry(
      builder: (context) {
        if (plugin.isOverlay) {
          return PluginOverlayWrapper(
            plugin: plugin,
            child: plugin.build(context),
          );
        }
        return PluginWrapper(
          plugin: plugin,
          position: position,
          size: size,
          showReset: isEntries,
          onClose: () => isEntries ? removeOverlay() : showEntries(),
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

  /// 保存当前位置
  static Future<void> resetPlugins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (Pluggable plugin in _plugins) {
        _resetPlugin(prefs, plugin.name);
      }
      // 入口
      _resetPlugin(prefs, Entries().name);
    } catch (e) {
      // 忽略错误
    }
  }

  static void _resetPlugin(SharedPreferences prefs, String name) {
    prefs.remove('overlay_position_${name}_x');
    prefs.remove('overlay_position_${name}_y');
    prefs.remove('overlay_size_${name}_width');
    prefs.remove('overlay_size_${name}_height');
  }

  static void onMessage(String message) {
    _onMessage?.call(message);
  }
}
