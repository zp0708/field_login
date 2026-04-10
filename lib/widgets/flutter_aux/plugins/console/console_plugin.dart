import 'dart:async';

import 'package:flutter/material.dart';
import '../pluggable.dart';
import './console_manager.dart';

class ConsolePlugin extends Pluggable {
  ConsolePlugin({Key? key}) {
    ConsoleManager.redirectDebugPrint();
  }

  @override
  String get name => 'console_panel';

  @override
  String get display => '控制台';

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return _ConsolePage();
  }
}

class _ConsolePage extends StatefulWidget {
  const _ConsolePage();

  @override
  State<_ConsolePage> createState() => _ConsolePageState();
}

class _ConsolePageState extends State<_ConsolePage> with WidgetsBindingObserver {
  List<ConsoleItem> _logList = <ConsoleItem>[];
  StreamSubscription? _subscription;
  ScrollController? _controller;
  bool _top = false;
  RegExp? _filterExp;

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _controller = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _logList = ConsoleManager.logData.toList();
    _subscription = ConsoleManager.streamController!.stream.listen((onData) {
      if (mounted) {
        if (_filterExp != null) {
          _logList = ConsoleManager.logData.where((e) {
            return _filterExp!.hasMatch(e.dateTime.toString()) || _filterExp!.hasMatch(e.message);
          }).toList();
        } else {
          _logList = ConsoleManager.logData.toList();
        }

        setState(() {});
        _controller!.jumpTo(_controller!.position.maxScrollExtent + 22); // 22 is a magic number
      }
    });
  }

  void _refreshConsole() {
    if (_filterExp != null) {
      _logList = ConsoleManager.logData.where((e) {
        return _filterExp!.hasMatch(e.dateTime.toString()) || _filterExp!.hasMatch(e.message);
      }).toList();
    } else {
      _logList = ConsoleManager.logData.toList();
    }
    setState(() {});
  }

  String _dateTimeString(ConsoleItem item) {
    String result = '';
    result = item.dateTime.toString().padRight(26, '0');
    result = '${result.substring(11, result.length - 3)} ';
    return result;
  }

  void _topOrBottom() {
    _top = !_top;
    if (_top) {
      _controller!.jumpTo(0);
    } else {
      _controller!.jumpTo(_controller!.position.maxScrollExtent);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            height: 45,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _filterExp = RegExp(value);
                      } else {
                        _filterExp = null;
                      }
                      _refreshConsole();
                    },
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'RegExp',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(50),
                        ),
                      ),
                      contentPadding: EdgeInsets.only(
                        top: 0,
                        bottom: 0,
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                ElevatedButton(
                  onPressed: _topOrBottom,
                  child: Text(
                    _top ? 'top' : 'bottom',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => ConsoleManager.clearLog(),
                  child: Text(
                    'clear',
                    style: TextStyle(fontSize: 12),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              controller: _controller,
              itemCount: _logList.length,
              itemBuilder: (BuildContext context, int index) {
                final idx = _logList.length - index - 1;
                final item = _logList[idx];
                return Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 3),
                  child: SelectableText.rich(
                    onTap: () => setState(() => item.show = !item.show),
                    TextSpan(
                      children: [
                        TextSpan(
                          text: _dateTimeString(item),
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'Courier',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: item.message,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Courier',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    maxLines: item.show ? null : 1,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
