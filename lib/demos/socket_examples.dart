// @Author: AI Assistant
// @Date: 2025/1/27
// @Desc: Simple usage examples for WebSocket client

import '../widgets/scoket/socket_client.dart';

/// Example 1: Basic Connection and Messaging
class BasicExample {
  final SocketClient _client = SocketClient.instance;

  Future<void> demo() async {
    // 1. Connect to WebSocket server
    bool connected = await _client.connect('ws://localhost:8080/chat');
    print('Connected: $connected');

    // 2. Add message listeners
    _client.addListener('chat_message', (message) {
      print('Chat: ${message.payload['content']}');
    });

    _client.addListener('notification', (message) {
      print('Notification: ${message.payload['title']}');
    });

    // 3. Send messages
    await _client.sendMessage(
      msgType: 'chat_message',
      payload: {
        'content': 'Hello World!',
        'user': 'flutter_user',
      },
    );

    // 4. Monitor connection state
    _client.stateStream.listen((state) {
      print('Connection state: $state');
    });

    // 5. Check connection status
    print('Is connected: ${_client.isConnected}');
    print('Listener count: ${_client.getListenerCount('chat_message')}');

    // 6. Cleanup when done
    _client.removeAllListeners('chat_message');
    _client.removeAllListeners('notification');
    // Connection auto-closes when no listeners remain
  }
}

/// Example 2: Configuration and Advanced Features
class AdvancedExample {
  final SocketClient _client = SocketClient.instance;

  Future<void> demo() async {
    // Configure heartbeat and reconnection
    _client.heartbeatInterval = Duration(seconds: 45);
    _client.reconnectInterval = Duration(seconds: 3);
    _client.maxReconnectAttempts = 3;

    await _client.connect('ws://example.com/ws');

    // Multiple listeners for same message type
    _client.addListener('system_event', _handleSystemEvent1);
    _client.addListener('system_event', _handleSystemEvent2);

    // Send heartbeat manually (usually automatic)
    await _client.sendMessage(
      msgType: 'heartbeat',
      payload: {'data': 'ping'},
    );

    // Get all registered message types
    List<String> types = _client.getRegisteredMessageTypes();
    print('Registered types: $types');
  }

  void _handleSystemEvent1(WebSocketMessage message) {
    print('Handler 1: ${message.payload}');
  }

  void _handleSystemEvent2(WebSocketMessage message) {
    print('Handler 2: ${message.payload}');
  }
}

/// Example 3: Error Handling and State Management
class ErrorHandlingExample {
  final SocketClient _client = SocketClient.instance;

  Future<void> demo() async {
    // Listen to connection state changes
    _client.stateStream.listen((state) {
      switch (state) {
        case WebSocketState.connected:
          print('✅ Connected successfully');
          break;
        case WebSocketState.connecting:
          print('🔄 Connecting...');
          break;
        case WebSocketState.reconnecting:
          print('🔄 Reconnecting...');
          break;
        case WebSocketState.error:
          print('❌ Connection error');
          break;
        case WebSocketState.disconnected:
          print('⚪ Disconnected');
          break;
      }
    });

    // Try to connect
    bool success = await _client.connect('ws://unreachable-server.com');
    if (!success) {
      print('Initial connection failed, but auto-reconnect will try again');
    }

    // Add listener to trigger reconnection attempts
    _client.addListener('test_message', (message) {
      print('Received test message: ${message.payload}');
    });

    // Try to send message (will fail if not connected)
    bool sent = await _client.sendMessage(
      msgType: 'test_message',
      payload: {'data': 'test'},
    );

    if (!sent) {
      print('Message sending failed - not connected');
    }
  }
}

/// Example 4: Message Format Demonstration
class MessageFormatExample {
  final SocketClient _client = SocketClient.instance;

  Future<void> demo() async {
    await _client.connect('ws://localhost:8080');

    // The WebSocket client automatically formats messages like this:
    /*
    {
      "msg_type": "your_message_type",
      "msg_id": "auto_generated_id", 
      "ts": 1234567890,
      "payload": {
        "your": "data"
      }
    }
    */

    // Heartbeat messages are automatically sent like this:
    /*
    {
      "msg_type": "heartbeat",
      "msg_id": "12345",
      "ts": 1234566,
      "payload": {
        "data": "ping"
      }
    }
    */

    // Send a custom message
    await _client.sendMessage(
      msgType: 'user_action',
      payload: {
        'action': 'login',
        'user_id': '12345',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    // Send with custom message ID
    await _client.sendMessage(
      msgType: 'custom_event',
      msgId: 'my_custom_id_123',
      payload: {
        'event': 'button_click',
        'button_id': 'submit_btn',
      },
    );
  }
}

/// Example 5: Real-world Chat Application
class ChatApplicationExample {
  final SocketClient _client = SocketClient.instance;
  final List<ChatMessage> _messages = [];

  Future<void> startChat(String username) async {
    // Connect to chat server
    await _client.connect('ws://chat.example.com/ws');

    // Listen to different message types
    _client.addListener('chat_message', _onChatMessage);
    _client.addListener('user_joined', _onUserJoined);
    _client.addListener('user_left', _onUserLeft);
    _client.addListener('typing_indicator', _onTypingIndicator);

    // Join chat room
    await _client.sendMessage(
      msgType: 'join_room',
      payload: {
        'username': username,
        'room': 'general',
      },
    );
  }

  void _onChatMessage(WebSocketMessage message) {
    final content = message.payload['content'] as String;
    final sender = message.payload['sender'] as String;
    final timestamp = DateTime.fromMillisecondsSinceEpoch(message.ts);

    _messages.add(ChatMessage(
      content: content,
      sender: sender,
      timestamp: timestamp,
    ));

    print('💬 $sender: $content');
  }

  void _onUserJoined(WebSocketMessage message) {
    final username = message.payload['username'] as String;
    print('👋 $username joined the chat');
  }

  void _onUserLeft(WebSocketMessage message) {
    final username = message.payload['username'] as String;
    print('👋 $username left the chat');
  }

  void _onTypingIndicator(WebSocketMessage message) {
    final username = message.payload['username'] as String;
    final isTyping = message.payload['is_typing'] as bool;
    print('✏️ $username is ${isTyping ? 'typing' : 'not typing'}');
  }

  Future<void> sendMessage(String content) async {
    await _client.sendMessage(
      msgType: 'chat_message',
      payload: {
        'content': content,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> sendTypingIndicator(bool isTyping) async {
    await _client.sendMessage(
      msgType: 'typing_indicator',
      payload: {
        'is_typing': isTyping,
      },
    );
  }

  void leaveChat() {
    _client.removeAllListeners('chat_message');
    _client.removeAllListeners('user_joined');
    _client.removeAllListeners('user_left');
    _client.removeAllListeners('typing_indicator');
    // Connection will auto-close since no listeners remain
  }
}

class ChatMessage {
  final String content;
  final String sender;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.sender,
    required this.timestamp,
  });
}
