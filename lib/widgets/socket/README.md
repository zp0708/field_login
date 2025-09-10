# WebSocket Client Utility - Complete Guide

A comprehensive WebSocket client utility built with dart:io, featuring singleton management, message handling, heartbeat, and automatic reconnection.

## ✨ Features

- ✅ **Singleton Management** - Single instance across the app
- ✅ **Type-based Message Listening** - Listen to specific message types
- ✅ **Message Sending** - Send structured messages to server
- ✅ **Automatic Heartbeat** - Configurable ping/pong mechanism
- ✅ **Smart Connection Management** - Auto-disconnect when no listeners
- ✅ **Automatic Reconnection** - Configurable retry strategy
- ✅ **State Management** - Track connection states
- ✅ **Error Handling** - Robust error recovery

## 🚀 Quick Start

### Basic Usage

```dart
import 'package:your_app/widgets/socket/socket_client.dart';

// Get singleton instance
final socketClient = SocketClient.instance;

// Connect to WebSocket server
await socketClient.connect('ws://localhost:8080/chat');

// Add message listener
socketClient.addListener('chat_message', (message) {
  print('Received chat: ${message.payload}');
});

// Send message
await socketClient.sendMessage(
  msgType: 'chat_message',
  payload: {
    'content': 'Hello World!',
    'user': 'john_doe',
  },
);

// Remove listener when done
socketClient.removeListener('chat_message', listener);
```

### Advanced Configuration

```dart
final socketClient = SocketClient.instance;

// Configure heartbeat and reconnection
socketClient.heartbeatInterval = Duration(seconds: 30);
socketClient.reconnectInterval = Duration(seconds: 5);
socketClient.maxReconnectAttempts = 3;

// Listen to connection state changes
socketClient.stateStream.listen((state) {
  switch (state) {
    case WebSocketState.connected:
      print('Connected to server');
      break;
    case WebSocketState.reconnecting:
      print('Attempting to reconnect...');
      break;
    case WebSocketState.error:
      print('Connection error occurred');
      break;
  }
});
```

## 📱 Message Format

All messages follow this structure:

```json
{
  "msg_type": "message_type",
  "msg_id": "unique_message_id", 
  "ts": 1234567890,
  "payload": {
    "data": "your_data_here"
  }
}
```

### Heartbeat Message

```json
{
  "msg_type": "heartbeat",
  "msg_id": "12345",
  "ts": 1234566,
  "payload": {
    "data": "ping"
  }
}
```

## 🔧 API Reference

### Connection Management

```dart
// Connect to server
Future<bool> connect(String url)

// Disconnect from server  
Future<void> disconnect()

// Check connection status
bool get isConnected

// Get current state
WebSocketState get state
```

### Message Handling

```dart
// Send message
Future<bool> sendMessage({
  required String msgType,
  Map<String, dynamic>? payload,
  String? msgId,
})

// Add message listener
void addListener(String msgType, MessageListener listener)

// Remove specific listener
void removeListener(String msgType, MessageListener listener)

// Remove all listeners for type
void removeAllListeners(String msgType)

// Get listener count
int getListenerCount(String msgType)

// Get registered message types
List<String> getRegisteredMessageTypes()
```

### Configuration

```dart
// Heartbeat configuration
Duration heartbeatInterval = Duration(seconds: 30);

// Reconnection configuration
Duration reconnectInterval = Duration(seconds: 5);
int maxReconnectAttempts = 5;
```

## 🎯 Usage Examples

### 1. Chat Application

```dart
class ChatService {
  final SocketClient _client = SocketClient.instance;
  
  Future<void> initializeChat() async {
    await _client.connect('ws://chat.example.com/ws');
    
    // Listen to different message types
    _client.addListener('chat_message', _onChatMessage);
    _client.addListener('user_joined', _onUserJoined);
    _client.addListener('user_left', _onUserLeft);
  }
  
  void _onChatMessage(WebSocketMessage message) {
    final content = message.payload['content'];
    final sender = message.payload['sender'];
    // Handle chat message
  }
  
  Future<void> sendChatMessage(String content) async {
    await _client.sendMessage(
      msgType: 'chat_message',
      payload: {
        'content': content,
        'sender': 'current_user',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}
```

### 2. Real-time Notifications

```dart
class NotificationService {
  final SocketClient _client = SocketClient.instance;
  
  Future<void> startListening() async {
    await _client.connect('ws://api.example.com/notifications');
    
    _client.addListener('notification', (message) {
      final notification = Notification.fromJson(message.payload);
      _showNotification(notification);
    });
    
    _client.addListener('alert', (message) {
      final alert = Alert.fromJson(message.payload);
      _showAlert(alert);
    });
  }
  
  void stopListening() {
    _client.removeAllListeners('notification');
    _client.removeAllListeners('alert');
    // Connection auto-closes when no listeners remain
  }
}
```

### 3. Game Communications

```dart
class GameClient {
  final SocketClient _client = SocketClient.instance;
  
  Future<void> joinGame(String gameId) async {
    await _client.connect('ws://game.example.com/ws');
    
    // Game event listeners
    _client.addListener('game_start', _onGameStart);
    _client.addListener('player_move', _onPlayerMove);
    _client.addListener('game_end', _onGameEnd);
    
    // Join game room
    await _client.sendMessage(
      msgType: 'join_game',
      payload: {'game_id': gameId, 'player_id': 'player123'},
    );
  }
  
  Future<void> makeMove(Map<String, dynamic> moveData) async {
    await _client.sendMessage(
      msgType: 'player_move',
      payload: moveData,
    );
  }
}
```

### 4. IoT Device Control

```dart
class IoTController {
  final SocketClient _client = SocketClient.instance;
  
  Future<void> connectToDevice(String deviceId) async {
    await _client.connect('ws://iot.example.com/device/$deviceId');
    
    _client.addListener('sensor_data', (message) {
      final sensorData = SensorData.fromJson(message.payload);
      _updateUI(sensorData);
    });
    
    _client.addListener('device_status', (message) {
      final status = message.payload['status'];
      _updateDeviceStatus(status);
    });
  }
  
  Future<void> sendCommand(String command, Map<String, dynamic> params) async {
    await _client.sendMessage(
      msgType: 'device_command',
      payload: {
        'command': command,
        'params': params,
      },
    );
  }
}
```

## 🔄 State Management Integration

### With Riverpod

```dart
final socketStateProvider = StreamProvider<WebSocketState>((ref) {
  return SocketClient.instance.stateStream;
});

final chatMessagesProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]) {
    SocketClient.instance.addListener('chat_message', _onMessage);
  }
  
  void _onMessage(WebSocketMessage message) {
    final chatMessage = ChatMessage.fromPayload(message.payload);
    state = [...state, chatMessage];
  }
  
  @override
  void dispose() {
    SocketClient.instance.removeAllListeners('chat_message');
    super.dispose();
  }
}
```

## ⚙️ Configuration Options

### Heartbeat Configuration

```dart
// Set heartbeat interval (default: 30 seconds)
SocketClient.instance.heartbeatInterval = Duration(seconds: 45);

// Heartbeat message format is automatically:
// {
//   "msg_type": "heartbeat",
//   "msg_id": "generated_id",
//   "ts": current_timestamp,
//   "payload": {"data": "ping"}
// }
```

### Reconnection Strategy

```dart
// Configure reconnection behavior
SocketClient.instance.reconnectInterval = Duration(seconds: 10);
SocketClient.instance.maxReconnectAttempts = 3;

// Reconnection delay increases with each attempt:
// Attempt 1: 10 seconds
// Attempt 2: 20 seconds  
// Attempt 3: 30 seconds
```

## 🛡️ Error Handling

```dart
// Listen to state changes for error handling
SocketClient.instance.stateStream.listen((state) {
  switch (state) {
    case WebSocketState.error:
      // Handle connection errors
      _showErrorDialog('Connection failed');
      break;
    case WebSocketState.reconnecting:
      // Show reconnecting indicator
      _showReconnectingSnackbar();
      break;
  }
});

// Handle message sending errors
final success = await SocketClient.instance.sendMessage(
  msgType: 'test',
  payload: {'data': 'test'},
);

if (!success) {
  print('Failed to send message - not connected');
}
```

## 🧹 Cleanup

```dart
class MyService {
  final SocketClient _client = SocketClient.instance;
  
  void dispose() {
    // Remove specific listeners
    _client.removeAllListeners('chat_message');
    _client.removeAllListeners('notifications');
    
    // Or disconnect explicitly
    _client.disconnect();
    
    // Full cleanup (rarely needed)
    _client.dispose();
  }
}
```

## 🔍 Debugging

```dart
// Monitor connection state
print('Current state: ${SocketClient.instance.state}');
print('Is connected: ${SocketClient.instance.isConnected}');

// Check active listeners
print('Message types: ${SocketClient.instance.getRegisteredMessageTypes()}');
print('Chat listeners: ${SocketClient.instance.getListenerCount('chat_message')}');

// Connection will auto-close when no listeners remain
```

## 🌟 Best Practices

1. **Remove listeners properly** - Always remove listeners when they're no longer needed
2. **Handle connection states** - Listen to state changes for better UX
3. **Use structured payloads** - Keep message payloads organized and typed
4. **Configure for your use case** - Adjust heartbeat and reconnection settings
5. **Handle errors gracefully** - Check message sending success and connection state
6. **Leverage auto-disconnect** - Let the client close connections when not needed

The WebSocket client automatically manages connections, handles reconnections, and provides a clean API for real-time communication in your Flutter applications!