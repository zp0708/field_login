import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './plugins/pluggable.dart';
import './widgets/drag_position.dart';
import './widgets/draggable_widget.dart';
import './widgets/plugin_bottom.dart';
import './widgets/plugin_header.dart';
import 'plugins/align_ruler.dart';
import 'plugins/color_sucker.dart';
import 'plugins/console/console_plugin.dart';
import 'plugins/device_info.dart';
import 'plugins/dump/network_data.dart';
import 'plugins/entries.dart';
import 'plugins/performance.dart';
import 'plugins/proxy_settings.dart';
import 'plugins/shared_preferences_plugin.dart';
import 'plugins/slow_animation_plugin.dart';
import 'plugins/widget_detail_inspector/widget_detail_inspector.dart';
import 'plugins/widget_info_inspector.dart';
import 'widgets/overlay_wrapper.dart';

final GlobalKey auxRepaintKey = GlobalKey();

class FlutterAux extends StatelessWidget {
  const FlutterAux({
    super.key,
    required this.child,
    this.plugins,
    this.floating,
    this.rect,
  });

  final Widget child;

  /// 支持的插件，默认支持所有的
  final List<Pluggable>? plugins;

  /// 浮窗位置, top 值为负数时表示距离屏幕底部的间距
  final Rect? rect;

  /// 浮窗组件
  final Widget? floating;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          RepaintBoundary(key: auxRepaintKey, child: child),
          MediaQuery(
            data: MediaQueryData.fromView(PlatformDispatcher.instance.views.first),
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => AuxPluginManager(
                    plugins: plugins ?? _defaultPlugins,
                    rect: rect,
                    floating: floating,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Pluggable> get _defaultPlugins {
    return [
      ProxySettings(),
      NetworkData(),
      AlignRulerPlugin(),
      if (kDebugMode) WidgetInfoInspector(),
      if (kDebugMode) WidgetDetailInspector(),
      ColorSucker(),
      SharedPreferencesPlugin(),
      SlowAnimationPlugin(),
      DeviceInfo(),
      ConsolePlugin(),
      Performance(),
    ];
  }

  static showMessage(BuildContext context, String message) {
    // BotToast.showText(text: message);
  }
}

class AuxPluginManager extends StatefulWidget {
  const AuxPluginManager({
    super.key,
    required this.plugins,
    this.rect,
    this.floating,
  });

  final List<Pluggable> plugins;

  final Rect? rect;

  final Widget? floating;

  @override
  State<AuxPluginManager> createState() => _AuxPluginManagerState();
}

class _AuxPluginManagerState extends State<AuxPluginManager> with WidgetsBindingObserver {
  OverlayEntry? _currentOverlay;

  Pluggable? _lastPlugin;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyPress);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyPress);
    super.dispose();
  }

  bool _handleKeyPress(KeyEvent e) {
    // 1. 只拦截按下事件 (KeyDownEvent)，忽略抬起 (KeyUpEvent)，防止重复触发
    if (e is KeyDownEvent && HardwareKeyboard.instance.isAltPressed) {
      final keyId = e.logicalKey.keyId;
      // cmd + w 关闭插件窗口
      if (e.logicalKey == LogicalKeyboardKey.keyW) {
        _removeOverlay();
      } else if (keyId >= 0x30 && keyId <= 0x39) {
        // 核心计算：用当前 keyId 减去 0x30，获取 0-9 的数字
        final int targetNumber = keyId - 0x30 - 1;
        // 打开 plugins 第 1 ～ 9 个插件
        if (targetNumber >= 0 && targetNumber < widget.plugins.length) {
          _showPlugin(widget.plugins[targetNumber]);
        }
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    Rect rect = widget.rect ?? Rect.fromLTWH(10, 10, 60, 60);
    final top = rect.top < 0 ? (screenSize.height + rect.top - rect.height) : rect.top;
    rect = Rect.fromLTWH(rect.left, top, rect.width, rect.height);
    return DraggableWidget(
      useDecoration: false,
      rect: rect,
      child: DragPosition(
        onTap: _onTap,
        child: widget.floating ?? const FlutterLogo(),
      ),
    );
  }

  void _onTap() {
    if (_currentOverlay != null) {
      _removeOverlay();
      return;
    }
    if (_lastPlugin != null) {
      _showPlugin(_lastPlugin!);
    } else {
      _showEntry();
    }
  }

  void _showEntry() {
    _showPlugin(
      Entries(
        plugins: widget.plugins,
        onPlugin: (value) => _showPlugin(value),
      ),
    );
  }

  void _showPlugin(Pluggable plugin) async {
    // 移除当前 overlay
    _removeOverlay();

    if (context.mounted) {
      _currentOverlay = getOverlay(plugin);
      Overlay.of(context).insert(_currentOverlay!);
      _lastPlugin = plugin;
    }
  }

  OverlayEntry getOverlay(Pluggable plugin) {
    final isEntries = plugin is Entries;
    return OverlayEntry(
      builder: (context) {
        if (plugin.isOverlay) {
          return PluginOverlayWrapper(
            plugin: plugin,
            onBack: !isEntries ? _showEntry : null,
            onClose: _removeOverlay,
            child: plugin.build(context),
          );
        }
        return DraggableWidget(
          cacheKey: plugin.name,
          rect: Rect.fromLTWH(
            100,
            100,
            plugin.size.width,
            plugin.size.height,
          ),
          child: Column(
            children: [
              DragPosition(
                child: PluginHeader(
                  plugin: plugin,
                  onBack: !isEntries ? _showEntry : null,
                  onClose: _removeOverlay,
                ),
              ),
              Expanded(child: plugin.build(context)),
              const PluginBottom(),
            ],
          ),
        );
      },
    );
  }

  /// 移除当前 overlay
  void _removeOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}
