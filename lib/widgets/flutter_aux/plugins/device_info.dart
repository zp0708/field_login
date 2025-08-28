import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../flutter_aux.dart';

import 'pluggable.dart';

class DeviceInfo extends Pluggable {
  @override
  String get name => 'device_info';

  @override
  String get display => '设备信息';

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return _DeviceInfo();
  }
}

class _DeviceInfo extends StatefulWidget {
  const _DeviceInfo();

  @override
  State<_DeviceInfo> createState() => _DeviceInfoPanelState();
}

class _DeviceInfoPanelState extends State<_DeviceInfo> {
  String _content = '';
  Map<String, dynamic> _deviceData = {};

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  void _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map dataMap = {};
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      dataMap = _readAndroidBuildData(androidDeviceInfo);
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      dataMap = _readIosDeviceInfo(iosDeviceInfo);
    }

    _deviceData = Map<String, dynamic>.from(dataMap);

    StringBuffer buffer = StringBuffer();
    dataMap.forEach((k, v) {
      buffer.write('$k:  $v\n');
    });
    _content = buffer.toString();
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname': data.utsname.sysname,
      'utsname.nodename': data.utsname.nodename,
      'utsname.release': data.utsname.release,
      'utsname.version': data.utsname.version,
      'utsname.machine': data.utsname.machine,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2C3E50),
            const Color(0xFF34495E),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3498DB).withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.phone_android,
              color: Color(0xFF3498DB),
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              Platform.isAndroid ? 'Android 设备' : 'iOS 设备',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return _buildActionButton(
      icon: Icons.copy,
      label: '复制',
      onTap: () => _copyData(_content),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildQuickInfo(),
        ),
      ),
    );
  }

  List<Widget> _buildQuickInfo() {
    List<Map<String, String>> quickInfoItems = [];
    List skipKeys = [];

    if (Platform.isAndroid) {
      skipKeys = ['model', 'brand', 'version.release', 'version.sdkInt'];
      quickInfoItems = [
        {'label': '设备型号', 'value': _deviceData['model'] ?? 'Unknown'},
        {'label': '品牌', 'value': _deviceData['brand'] ?? 'Unknown'},
        {'label': 'Android 版本', 'value': _deviceData['version.release'] ?? 'Unknown'},
        {'label': 'SDK 版本', 'value': _deviceData['version.sdkInt']?.toString() ?? 'Unknown'},
      ];
    } else if (Platform.isIOS) {
      skipKeys = ['name', 'model', 'systemVersion', 'systemName'];
      quickInfoItems = [
        {'label': '设备名称', 'value': _deviceData['name'] ?? 'Unknown'},
        {'label': '设备型号', 'value': _deviceData['model'] ?? 'Unknown'},
        {'label': '系统版本', 'value': _deviceData['systemVersion'] ?? 'Unknown'},
        {'label': '系统名称', 'value': _deviceData['systemName'] ?? 'Unknown'},
      ];
    }

    final widgets = quickInfoItems
        .map((item) => _buildInfoCard(
              label: item['label']!,
              value: item['value']!,
            ))
        .toList();

    _deviceData.forEach((key, value) {
      if (!skipKeys.contains(key)) {
        widgets.add(_buildInfoCard(
          label: key,
          value: value?.toString() ?? 'Unknown',
        ));
      }
    });

    return widgets;
  }

  Widget _buildInfoCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withAlpha(200),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SelectableText(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 复制数据到剪贴板
  void _copyData(String data) {
    Clipboard.setData(ClipboardData(text: data));
    if (Platform.isIOS) {
      FlutterAux.onMessage('数据已复制到剪贴板');
    }
  }
}
