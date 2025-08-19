import 'dart:io';

import 'package:flutter/material.dart';
import 'package:system_info2/system_info2.dart';

import 'pluggable.dart';

class CpuInfoPlugin extends Pluggable {
  @override
  String get name => 'cpu_info';

  @override
  String get display => 'CUP信息';

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return _CpuInfoPage();
  }
}

class _CpuInfoPage extends StatefulWidget {
  const _CpuInfoPage();

  @override
  _CpuInfoPageState createState() => _CpuInfoPageState();
}

class _CpuInfoPageState extends State<_CpuInfoPage> {
  var _deviceInfo = <Map<String, String>>[];

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Text('Only available on Android device'),
        ),
      );
    }
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: ListView.separated(
          itemBuilder: (ctx, index) => ListTile(
            title: Text(_deviceInfo[index].keys.first),
            trailing: Text(_deviceInfo[index].values.first),
          ),
          separatorBuilder: (ctx, index) => Divider(),
          itemCount: _deviceInfo.length,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) _setupData();
  }

  _setupData() {
    const int MEGABYTE = 1024 * 1024;
    final deviceInfo = <Map<String, String>>[];
    deviceInfo.addAll([
      {'Kernel architecture': SysInfo.kernelArchitecture},
      {'Kernel bitness': '${SysInfo.kernelBitness}'},
      {'Kernel name': SysInfo.kernelName},
      {'Kernel version': SysInfo.kernelVersion},
      {'Operating system name': SysInfo.operatingSystemName},
      {'Operating system ': SysInfo.operatingSystemVersion},
      {'User directory': SysInfo.userDirectory},
      {'User id': SysInfo.userId},
      {'User name': SysInfo.userName},
      {'User space bitness': '${SysInfo.userSpaceBitness}'},
      {'Total physical memory': '${SysInfo.getTotalPhysicalMemory() ~/ MEGABYTE} MB'},
      {'Free physical memory': '${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB'},
      {'Total virtual memory': '${SysInfo.getTotalVirtualMemory() ~/ MEGABYTE} MB'},
      {'Free virtual memory': '${SysInfo.getFreeVirtualMemory() ~/ MEGABYTE} MB'},
      {'Virtual memory size': '${SysInfo.getVirtualMemorySize() ~/ MEGABYTE} MB'},
    ]);

    final processors = SysInfo.processors;
    deviceInfo.add(
      {'Number of processors': '${processors.length}'},
    );
    for (var processor in processors) {
      deviceInfo.addAll([
        {'[${processors.indexOf(processor)}] Architecture': '${processor.architecture}'},
        {'[${processors.indexOf(processor)}] Name': processor.name},
        {'[${processors.indexOf(processor)}] Socket': '${processor.socket}'},
        {'[${processors.indexOf(processor)}] Vendor': processor.vendor},
      ]);
    }
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _deviceInfo = deviceInfo;
      });
    });
  }
}
