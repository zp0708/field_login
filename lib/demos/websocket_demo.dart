import 'dart:io';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebsocketDemo extends StatefulWidget {
  const WebsocketDemo({super.key});

  @override
  State<WebsocketDemo> createState() => _WebsocketDemoState();
}

class _WebsocketDemoState extends State<WebsocketDemo> {
  IO.Socket? _socket;

  void _onconnet() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
    IO.Socket socket = IO.io(
      'http://localhost:9901',
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );
    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
    });
    socket.onConnectError((_) => print(_));
    socket.on('message', (data) => print(data));
    socket.onDisconnect((_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));
    socket.onerror((_) => print(_));
    socket.connect();
    _socket = socket;
  }

  void _onconnet_websocket() async {
    try {
      final socket = await WebSocket.connect('ws://localhost:9901/socket.io/?EIO=4&transport=websocket');

      print('Connected to WebSocket');

      socket.listen(
        (data) {
          print('Received: $data');
        },
        onDone: () {
          print('WebSocket closed');
        },
        onError: (error) {
          print('Error: $error');
        },
      );

      // 发送数据
      socket.add('Hello Server');
    } catch (e) {
      print('Error connecting: $e');
    }
  }

  void _connect_channel() async {
    final wsUrl = Uri.parse('ws://localhost:9901');
    final channel = WebSocketChannel.connect(wsUrl);

    await channel.ready;

    channel.stream.listen((message) {
      print(message);
    });
    Future.delayed(Duration(seconds: 10), () => channel.sink.close(1000, '我要断开'));
  }

  @override
  void dispose() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Websocket'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        alignment: Alignment.center,
        child: ElevatedButton(
          onPressed: _onconnet,
          child: Text('链接'),
        ),
      ),
    );
  }
}
