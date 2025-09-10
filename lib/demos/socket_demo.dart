// @Author: AI Assistant
// @Date: 2025/1/27
// @Desc: WebSocket client demo

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/scoket/socket_client.dart';

/// Chat message model
class ChatMessage {
  final String id;
  final String content;
  final String sender;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
  });

  factory ChatMessage.fromPayload(Map<String, dynamic> payload) {
    return ChatMessage(
      id: payload['id'] ?? '',
      content: payload['content'] ?? '',
      sender: payload['sender'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(payload['timestamp'] ?? 0),
    );
  }
}

/// Chat state provider
final chatMessagesProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]) {
    _setupListeners();
  }

  void _setupListeners() {
    // Listen to chat messages
    SocketClient.instance.addListener('chat_message', (message) {
      final chatMessage = ChatMessage.fromPayload(message.payload);
      state = [...state, chatMessage];
    });

    SocketClient.instance.addListener('heartbeat', (message) {
      final chatMessage = ChatMessage.fromPayload(message.payload);
      state = [...state, chatMessage];
    });

    // Listen to system messages
    SocketClient.instance.addListener('system_message', (message) {
      final content = message.payload['content'] ?? '';
      final systemMessage = ChatMessage(
        id: message.msgId,
        content: content,
        sender: 'System',
        timestamp: DateTime.fromMillisecondsSinceEpoch(message.ts),
      );
      state = [...state, systemMessage];
    });
  }

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  void clearMessages() {
    state = [];
  }

  @override
  void dispose() {
    SocketClient.instance.removeAllListeners('chat_message');
    SocketClient.instance.removeAllListeners('system_message');
    super.dispose();
  }
}

/// WebSocket connection state provider
final socketStateProvider = StreamProvider<WebSocketState>((ref) {
  return SocketClient.instance.stateStream;
});

/// WebSocket demo page
class SocketDemo extends ConsumerStatefulWidget {
  const SocketDemo({super.key});

  @override
  ConsumerState<SocketDemo> createState() => _SocketDemoState();
}

class _SocketDemoState extends ConsumerState<SocketDemo> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _urlController = TextEditingController(text: 'ws://localhost:8080/chat');
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _urlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _connect() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showSnackBar('Please enter WebSocket URL', Colors.red);
      return;
    }

    final success = await SocketClient.instance.connect(url);
    if (success) {
      _showSnackBar('Connected successfully', Colors.green);
    } else {
      _showSnackBar('Connection failed', Colors.red);
    }
  }

  Future<void> _disconnect() async {
    await SocketClient.instance.disconnect();
    _showSnackBar('Disconnected', Colors.orange);
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final success = await SocketClient.instance.sendMessage(
      msgType: 'chat_message',
      payload: {
        'content': content,
        'sender': 'Flutter User',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    if (success) {
      // Add message to local state for immediate feedback
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        sender: 'You',
        timestamp: DateTime.now(),
      );
      ref.read(chatMessagesProvider.notifier).addMessage(message);
      _messageController.clear();
      _scrollToBottom();
    } else {
      _showSnackBar('Failed to send message', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final socketState = ref.watch(socketStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          socketState.when(
            data: (state) => Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStateColor(state),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStateText(state),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'WebSocket URL',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _connect,
                        icon: const Icon(Icons.link),
                        label: const Text('Connect'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _disconnect,
                        icon: const Icon(Icons.link_off),
                        label: const Text('Disconnect'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),

          // Messages list
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet.\nConnect and start chatting!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.sender == 'You';

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.sender,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isMe ? Colors.white70 : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message.content,
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(message.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe ? Colors.white54 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStateColor(WebSocketState state) {
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

  String _getStateText(WebSocketState state) {
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

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
