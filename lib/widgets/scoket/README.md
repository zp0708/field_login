# WebSocket Client Utility

A complete WebSocket client utility built with dart:io, featuring singleton management, message handling, heartbeat, and automatic reconnection.

## ✨ Features

- ✅ **Singleton Management** - Single instance across the app via `SocketClient.instance`
- ✅ **Type-based Message Listening** - Listen to specific message types  
- ✅ **Message Sending** - Send structured messages to server
- ✅ **Automatic Heartbeat** - Configurable ping/pong with format: `{"msg_type":"heartbeat","msg_id":"12345","ts":1234566,"payload":{"data":"ping"}}`
- ✅ **Smart Connection Management** - Auto-disconnect when no listeners remain
- ✅ **Automatic Reconnection** - Configurable retry strategy with exponential backoff
- ✅ **State Management** - Track connection states (disconnected, connecting, connected, reconnecting, error)
- ✅ **Error Handling** - Robust error recovery

## 🚀 Quick Start

### Basic Usage

```dart
import 'package:your_app/widgets/scoket/socket_client.dart';

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
socketClient.removeAllListeners('chat_message');
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

The heartbeat is automatically sent every 30 seconds (configurable):

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

// Listen to state changes
Stream<WebSocketState> get stateStream
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
// Heartbeat configuration (default: 30 seconds)
SocketClient.instance.heartbeatInterval = Duration(seconds: 45);

// Reconnection configuration (default: 5 seconds, max 5 attempts)
SocketClient.instance.reconnectInterval = Duration(seconds: 10);
SocketClient.instance.maxReconnectAttempts = 3;
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

## 🛡️ Error Handling

```dart
// Listen to state changes for error handling
SocketClient.instance.stateStream.listen((state) {
  switch (state) {
    case WebSocketState.error:
      _showErrorDialog('Connection failed');
      break;
    case WebSocketState.reconnecting:
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

## 🔍 Key Features

### 1. Singleton Management
- Access via `SocketClient.instance` anywhere in your app
- Ensures single connection across the entire application

### 2. Type-based Message Listening
- Listen to specific message types: `addListener('chat_message', callback)`
- Multiple listeners per message type supported
- Automatic cleanup when listeners are removed

### 3. Smart Connection Management
- **Auto-disconnect**: Connection closes when no active listeners remain
- **Auto-reconnect**: Reconnects automatically if listeners exist
- **State tracking**: Monitor connection states via `stateStream`

### 4. Automatic Heartbeat
- Configurable interval (default: 30 seconds)
- Standard format: `{"msg_type":"heartbeat","msg_id":"12345","ts":1234566,"payload":{"data":"ping"}}`
- Handles heartbeat responses automatically

### 5. Reconnection Strategy
- **Exponential backoff**: Delay increases with each retry attempt
- **Max attempts**: Configurable maximum retry attempts
- **Smart reconnect**: Only reconnects if active listeners exist

### 6. Message Structure
All messages use consistent JSON format with `msg_type`, `msg_id`, `ts`, and `payload` fields.

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

## 🌟 Best Practices

1. **Remove listeners properly** - Always remove listeners when they're no longer needed
2. **Handle connection states** - Listen to state changes for better UX  
3. **Use structured payloads** - Keep message payloads organized and typed
4. **Configure for your use case** - Adjust heartbeat and reconnection settings
5. **Handle errors gracefully** - Check message sending success and connection state
6. **Leverage auto-disconnect** - Let the client close connections when not needed

The WebSocket client automatically manages connections, handles reconnections, and provides a clean API for real-time communication in your Flutter applications!