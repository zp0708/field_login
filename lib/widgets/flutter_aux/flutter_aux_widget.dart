import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './plugins/pluggable.dart';
import './widgets/draggable_widget.dart';
import 'plugin_wrapper.dart';
import 'plugins/align_ruler.dart';
import 'plugins/color_sucker.dart';
import 'plugins/console/console_plugin.dart';
import 'plugins/device_info.dart';
import 'plugins/dump/network_data.dart';
import 'plugins/easy_localization_log/easy_localization_log.dart';
import 'plugins/entries.dart';
import 'plugins/performance.dart';
import 'plugins/proxy_settings.dart';
import 'plugins/websocket_plugin.dart';
import 'plugins/widget_detail_inspector/widget_detail_inspector.dart';
import 'plugins/widget_info_inspector.dart';

class AuxWidget extends StatelessWidget {
  const AuxWidget({
    super.key,
    required this.child,
    this.plugins,
  });

  final Widget child;

  final List<Pluggable>? plugins;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        child: Stack(
          children: [
            child,
            MediaQuery(
              data: MediaQueryData.fromView(PlatformDispatcher.instance.views.first),
              child: Localizations(
                locale: Locale('en', 'US'),
                delegates: context.localizationDelegates,
                child: ScaffoldMessenger(
                  child: Overlay(
                    initialEntries: [
                      OverlayEntry(
                        builder: (context) => AuxManager(plugins: plugins),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuxManager extends StatefulWidget {
  const AuxManager({super.key, this.plugins});

  final List<Pluggable>? plugins;

  @override
  State<AuxManager> createState() => _AuxOverlayState();
}

class _AuxOverlayState extends State<AuxManager> {
  late List<Pluggable>? _plugins;

  OverlayEntry? _currentOverlay;

  late Pluggable _entry;

  @override
  void initState() {
    super.initState();
    _entry = Entries(onPlugin: (value) => showPlugin(value));
    _plugins =
        widget.plugins ??
        [
          ProxySettings(),
          NetworkData(),
          DeviceInfo(),
          ConsolePlugin(),
          AlignRulerPlugin(),
          WidgetInfoInspector(),
          WidgetDetailInspector(),
          ColorSucker(),
          Performance(),
          WebsocketPlugin(),
          EasyLocalizationLog(),
        ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showPlugin(_entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(top: 200, left: 200, child: FlutterLogo(size: 100));
  }

  void showPlugin(Pluggable plugin) async {
    // 移除当前 overlay
    removeOverlay();

    // 异步恢复保存的位置和大小
    if (context.mounted) {
      _currentOverlay = getOverlay(plugin);
      Overlay.of(context).insert(_currentOverlay!);
    }
  }

  OverlayEntry getOverlay(Pluggable plugin) {
    return OverlayEntry(
      builder: (context) {
        if (plugin.isOverlay) {
          return PluginOverlayWrapper(
            plugin: plugin,
            child: plugin.build(context),
          );
        }
        return DraggableWidget(
          plugin: plugin,
          child: plugin.build(context),
        );
      },
    );
  }

  /// 移除当前 overlay
  void removeOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}
