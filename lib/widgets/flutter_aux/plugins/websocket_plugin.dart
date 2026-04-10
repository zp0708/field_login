// @Author: AI Assistant
// @Date: 2025/1/27
// @Desc: WebSocket client demo

import 'package:flutter/material.dart';
import 'package:manicure/third/flutter_aux/plugins/pluggable.dart';
import 'package:manicure/third/socket_io/socket_client.dart';
import 'package:manicure/third/socket_io/socket_message.dart';

class WebsocketPlugin extends Pluggable {
  @override
  String get name => 'websocket_plugin';

  @override
  String get display => 'Websocket';

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return const WebSocketPage();
  }
}

/// WebSocket demo page
class WebSocketPage extends StatefulWidget {
  const WebSocketPage({super.key});

  @override
  State<WebSocketPage> createState() => _WebSocketPageState();
}

class _WebSocketPageState extends State<WebSocketPage> {
  final List<WebSocketMessage> _messages = [];
  WebSocketState _state = WebSocketState.disconnected;

  @override
  void initState() {
    super.initState();
    _state = SocketClient.instance.state;
    _connect();
  }

  @override
  void dispose() {
    super.dispose();
    SocketClient.instance.onReceivedMessage = null;
    SocketClient.instance.onStateChanged = null;
  }

  Future<void> _connect() async {
    SocketClient.instance.onReceivedMessage = ((message) {
      _messages.add(message);
      WidgetsBinding.instance.addPostFrameCallback((t) {
        setState(() {});
      });
    });
    SocketClient.instance.onStateChanged = ((s) {
      _state = s;
      WidgetsBinding.instance.addPostFrameCallback((t) {
        setState((){});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = _getStateText(_state);
    List<String> types = SocketClient.instance.getRegisteredMessageTypes();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStateColor(_state),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '监听数: ${types.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: types.length,
                    itemBuilder: (context, index) {
                      final t = types[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStateColor(_state),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (_state == WebSocketState.connected) {
                          SocketClient.instance.disconnect();
                        } else {
                          SocketClient.instance.reconnect();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _state == WebSocketState.connected ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _state == WebSocketState.connected ? '断开' : '链接',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.msgType,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.payload.toString(),
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message.ts),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStateColor(WebSocketState? state) {
    if (state == null) return Colors.red;
    switch (state) {
      case WebSocketState.connected:
        return Colors.green;
      case WebSocketState.connecting:
        return Colors.orange;
      case WebSocketState.reconnecting:
        return Colors.amber;
      case WebSocketState.error:
        return Colors.red;
      case WebSocketState.disconnected:
        return Colors.grey;
    }
  }

  String _getStateText(WebSocketState? state) {
    if (state == null) return '';
    switch (state) {
      case WebSocketState.connected:
        return 'Connected';
      case WebSocketState.connecting:
        return 'Connecting';
      case WebSocketState.reconnecting:
        return 'Reconnecting';
      case WebSocketState.error:
        return 'Error';
      case WebSocketState.disconnected:
        return 'Disconnected';
    }
  }

  String _formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return dateTime.toString();
  }
}
