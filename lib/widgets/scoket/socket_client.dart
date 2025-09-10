// @Author: AI Assistant
// @Date: 2025/1/27
// @Desc: Complete WebSocket utility with singleton management

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// WebSocket message model
class WebSocketMessage {
  final String msgType;
  final String msgId;
  final int ts;
  final Map<String, dynamic> payload;

  WebSocketMessage({
    required this.msgType,
    required this.msgId,
    required this.ts,
    required this.payload,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      msgType: json['msg_type'] ?? '',
      msgId: json['msg_id'] ?? '',
      ts: json['ts'] ?? DateTime.now().millisecondsSinceEpoch,
      payload: json['payload'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg_type': msgType,
      'msg_id': msgId,
      'ts': ts,
      'payload': payload,
    };
  }
}

/// WebSocket connection states
enum WebSocketState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// Message listener callback
typedef MessageListener = void Function(WebSocketMessage message);

/// WebSocket client utility with singleton management
class SocketClient {
  static SocketClient? _instance;
  static SocketClient get instance => _instance ??= SocketClient._internal();

  SocketClient._internal();

  // WebSocket connection
  WebSocket? _webSocket;

  // Connection state
  WebSocketState _state = WebSocketState.disconnected;
  WebSocketState get state => _state;

  // Connection URL
  String? _url;

  // Message listeners by type
  final Map<String, List<MessageListener>> _listeners = {};

  // Stream controllers for state changes
  final StreamController<WebSocketState> _stateController = StreamController<WebSocketState>.broadcast();
  Stream<WebSocketState> get stateStream => _stateController.stream;

  // Heartbeat timer
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  // Configuration
  Duration heartbeatInterval = const Duration(seconds: 30);
  Duration reconnectInterval = const Duration(seconds: 5);
  int maxReconnectAttempts = 5;
  int _reconnectAttempts = 0;

  // Random generator for message IDs
  final Random _random = Random();

  /// Connect to WebSocket server
  Future<bool> connect(String url) async {
    if (_state == WebSocketState.connected || _state == WebSocketState.connecting) {
      print('WebSocket already connected or connecting');
      return _state == WebSocketState.connected;
    }

    _url = url;
    _setState(WebSocketState.connecting);

    try {
      _webSocket = await WebSocket.connect(url);
      _setState(WebSocketState.connected);
      _reconnectAttempts = 0;

      // Set up message listener
      _webSocket!.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDisconnected,
        cancelOnError: false,
      );

      // Start heartbeat
      _startHeartbeat();

      print('WebSocket connected to $url');
      return true;
    } catch (e) {
      print('WebSocket connection failed: $e');
      _setState(WebSocketState.error);
      _scheduleReconnect();
      return false;
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _stopHeartbeat();
    _stopReconnectTimer();

    if (_webSocket != null) {
      await _webSocket!.close();
      _webSocket = null;
    }

    _setState(WebSocketState.disconnected);
    print('WebSocket disconnected');
  }

  /// Send message to server
  Future<bool> sendMessage({
    required String msgType,
    Map<String, dynamic>? payload,
    String? msgId,
  }) async {
    if (_state != WebSocketState.connected || _webSocket == null) {
      print('WebSocket not connected, cannot send message');
      return false;
    }

    try {
      final message = WebSocketMessage(
        msgType: msgType,
        msgId: msgId ?? _generateMessageId(),
        ts: DateTime.now().millisecondsSinceEpoch,
        payload: payload ?? {},
      );

      final jsonString = jsonEncode(message.toJson());
      _webSocket!.add(jsonString);

      print('Message sent: $jsonString');
      return true;
    } catch (e) {
      print('Failed to send message: $e');
      return false;
    }
  }

  /// Add listener for specific message type
  void addListener(String msgType, MessageListener listener) {
    if (!_listeners.containsKey(msgType)) {
      _listeners[msgType] = [];
    }
    _listeners[msgType]!.add(listener);
    print('Added listener for message type: $msgType');
  }

  /// Remove listener for specific message type
  void removeListener(String msgType, MessageListener listener) {
    if (_listeners.containsKey(msgType)) {
      _listeners[msgType]!.remove(listener);

      // Clean up empty listener lists
      if (_listeners[msgType]!.isEmpty) {
        _listeners.remove(msgType);
        print('Removed all listeners for message type: $msgType');
      }

      // Disconnect if no listeners remain
      if (_listeners.isEmpty && _state == WebSocketState.connected) {
        print('No listeners remaining, disconnecting...');
        disconnect();
      }
    }
  }

  /// Remove all listeners for specific message type
  void removeAllListeners(String msgType) {
    if (_listeners.containsKey(msgType)) {
      _listeners.remove(msgType);
      print('Removed all listeners for message type: $msgType');

      // Disconnect if no listeners remain
      if (_listeners.isEmpty && _state == WebSocketState.connected) {
        print('No listeners remaining, disconnecting...');
        disconnect();
      }
    }
  }

  /// Get current listener count for a message type
  int getListenerCount(String msgType) {
    return _listeners[msgType]?.length ?? 0;
  }

  /// Get all registered message types
  List<String> getRegisteredMessageTypes() {
    return _listeners.keys.toList();
  }

  /// Check if WebSocket is connected
  bool get isConnected => _state == WebSocketState.connected;

  /// Handle incoming messages
  void _onMessage(dynamic data) {
    try {
      final jsonData = jsonDecode(data.toString());
      final message = WebSocketMessage.fromJson(jsonData);

      print('Received message: ${message.msgType}');

      // Handle heartbeat response
      if (message.msgType == 'heartbeat_response' || message.msgType == 'pong') {
        print('Heartbeat response received');
        return;
      }

      // Notify listeners
      if (_listeners.containsKey(message.msgType)) {
        for (final listener in _listeners[message.msgType]!) {
          try {
            listener(message);
          } catch (e) {
            print('Error in message listener: $e');
          }
        }
      }
    } catch (e) {
      print('Failed to parse message: $e');
    }
  }

  /// Handle connection errors
  void _onError(dynamic error) {
    print('WebSocket error: $error');
    _setState(WebSocketState.error);
    _scheduleReconnect();
  }

  /// Handle disconnection
  void _onDisconnected() {
    print('WebSocket disconnected');
    _setState(WebSocketState.disconnected);
    _stopHeartbeat();

    // Only reconnect if we have active listeners
    if (_listeners.isNotEmpty) {
      _scheduleReconnect();
    }
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (timer) {
      _sendHeartbeat();
    });
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Send heartbeat message
  void _sendHeartbeat() {
    sendMessage(
      msgType: 'heartbeat',
      payload: {'data': 'ping'},
    );
  }

  /// Schedule reconnection
  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      print('Max reconnect attempts reached, giving up');
      _setState(WebSocketState.error);
      return;
    }

    _stopReconnectTimer();
    _setState(WebSocketState.reconnecting);

    final delay = Duration(seconds: reconnectInterval.inSeconds * (_reconnectAttempts + 1));
    print('Scheduling reconnect in ${delay.inSeconds} seconds (attempt ${_reconnectAttempts + 1})');

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      if (_url != null && _listeners.isNotEmpty) {
        connect(_url!);
      }
    });
  }

  /// Stop reconnect timer
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Update connection state
  void _setState(WebSocketState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(_state);
      print('WebSocket state changed to: $_state');
    }
  }

  /// Generate unique message ID
  String _generateMessageId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}';
  }

  /// Dispose resources
  void dispose() {
    _stopHeartbeat();
    _stopReconnectTimer();
    _webSocket?.close();
    _stateController.close();
    _listeners.clear();
  }
}