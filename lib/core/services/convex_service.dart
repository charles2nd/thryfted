import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';

class ConvexService {
  static String get _convexUrl {
    final url = dotenv.env['CONVEX_URL'];
    if (url == null || url.isEmpty) {
      AppLogger.e('❌ CONVEX_URL not found in .env file');
      AppLogger.d('Available env vars: ${dotenv.env.keys.toList()}');
      throw Exception('CONVEX_URL not configured in environment');
    }
    
    // Convex WebSocket connections use the same domain but wss protocol
    // No additional path needed - Convex handles WebSocket upgrades automatically
    final wsUrl = url.replaceFirst('https://', 'wss://');
    AppLogger.d('ℹ️ Using Convex WebSocket URL: $wsUrl');
    return wsUrl;
  }
  
  WebSocketChannel? _channel;
  final Map<String, StreamController> _subscriptions = {};
  final Map<String, Completer> _pendingRequests = {};
  int _requestId = 0;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  // Singleton pattern
  static final ConvexService _instance = ConvexService._internal();
  factory ConvexService() => _instance;
  ConvexService._internal();

  bool get isConnected => _isConnected;

  // Initialize WebSocket connection
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final wsUrl = _convexUrl;
      AppLogger.d('🔄 Connecting to Convex WebSocket: $wsUrl');
      
      // Create WebSocket connection (remove protocol specification)
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Set up listeners FIRST before marking as connected
      _channel!.stream.listen(
        (message) {
          AppLogger.d('📨 WebSocket message received: $message');
          _handleMessage(message);
        },
        onError: (error) {
          AppLogger.e('❌ WebSocket error: $error');
          _handleError(error);
        },
        onDone: () {
          AppLogger.d('🔌 WebSocket connection closed');
          _handleDone();
        },
      );

      // Only mark as connected after setting up listeners
      _isConnected = true;
      _startPingTimer();
      
      AppLogger.d('✅ Convex WebSocket connected successfully');
    } catch (e, stackTrace) {
      AppLogger.e('❌ Failed to connect to Convex: $e');
      AppLogger.e('📍 Stack trace: $stackTrace');
      _isConnected = false;
      _scheduleReconnect();
    }
  }
  
  // Test HTTP connection to Convex
  Future<void> _testHttpConnection() async {
    try {
      final httpUrl = dotenv.env['CONVEX_URL']!;
      AppLogger.d('Testing HTTP connection to: $httpUrl');
      
      final response = await http.get(Uri.parse(httpUrl)).timeout(
        const Duration(seconds: 10),
      );
      
      AppLogger.d('HTTP test response: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 404) {
        throw Exception('HTTP test failed with status: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.e('HTTP connection test failed: $e');
      throw Exception('Cannot reach Convex server: $e');
    }
  }
  
  // Send initial handshake/authentication message
  void _sendInitialHandshake() {
    try {
      // For now, send a simple ping to test connection
      // In a real implementation, you'd send authentication token here
      final handshake = {
        'type': 'ping',
        'id': 'handshake_${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      AppLogger.d('Sending handshake message');
      _channel?.sink.add(jsonEncode(handshake));
    } catch (e) {
      AppLogger.e('Failed to send handshake: $e');
    }
  }

  // Disconnect WebSocket
  void disconnect() {
    _cancelTimers();
    _channel?.sink.close(status.normalClosure);
    _isConnected = false;
    _clearSubscriptions();
  }

  // Subscribe to a query
  Stream<dynamic> subscribe(String functionName, Map<String, dynamic> args) {
    final subscriptionId = '${functionName}_${DateTime.now().millisecondsSinceEpoch}';
    final controller = StreamController.broadcast();
    
    _subscriptions[subscriptionId] = controller;
    
    _sendMessage({
      'type': 'subscribe',
      'id': subscriptionId,
      'function': functionName,
      'args': args,
    });

    return controller.stream;
  }

  // Unsubscribe from a query
  void unsubscribe(String subscriptionId) {
    if (_subscriptions.containsKey(subscriptionId)) {
      _sendMessage({
        'type': 'unsubscribe',
        'id': subscriptionId,
      });
      
      _subscriptions[subscriptionId]?.close();
      _subscriptions.remove(subscriptionId);
    }
  }

  // Execute a mutation
  Future<dynamic> mutation(String functionName, Map<String, dynamic> args) async {
    final requestId = '${_requestId++}';
    final completer = Completer();
    
    _pendingRequests[requestId] = completer;
    
    _sendMessage({
      'type': 'mutation',
      'id': requestId,
      'function': functionName,
      'args': args,
    });

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _pendingRequests.remove(requestId);
        throw TimeoutException('Mutation timeout: $functionName');
      },
    );
  }

  // Execute a query (one-time)
  Future<dynamic> query(String functionName, Map<String, dynamic> args) async {
    final requestId = '${_requestId++}';
    final completer = Completer();
    
    _pendingRequests[requestId] = completer;
    
    _sendMessage({
      'type': 'query',
      'id': requestId,
      'function': functionName,
      'args': args,
    });

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _pendingRequests.remove(requestId);
        throw TimeoutException('Query timeout: $functionName');
      },
    );
  }

  // HTTP fallback for mutations (when WebSocket is not available)
  Future<dynamic> httpMutation(String functionName, Map<String, dynamic> args) async {
    try {
      final response = await _httpPost('/api/mutation', {
        'function': functionName,
        'args': args,
      });
      
      return response['data'];
    } catch (e) {
      AppLogger.e('HTTP mutation failed: $e');
      rethrow;
    }
  }

  // Send message through WebSocket
  void _sendMessage(Map<String, dynamic> message) {
    if (!_isConnected) {
      AppLogger.w('⚠️ Cannot send message: WebSocket not connected');
      AppLogger.d('Connection state - isConnected: $_isConnected, channel: ${_channel != null}');
      return;
    }

    try {
      final jsonMessage = jsonEncode(message);
      AppLogger.d('Sending message: ${message['type']} (${jsonMessage.length} chars)');
      _channel?.sink.add(jsonMessage);
    } catch (e, stackTrace) {
      AppLogger.e('❌ Failed to send message', e, stackTrace);
    }
  }

  // Handle incoming messages
  void _handleMessage(dynamic data) {
    try {
      AppLogger.d('ℹ️ Received WebSocket message: ${data.toString().substring(0, 100)}...');
      final message = jsonDecode(data);
      final type = message['type'];
      final id = message['id'];

      switch (type) {
        case 'subscription_update':
          if (_subscriptions.containsKey(id)) {
            _subscriptions[id]?.add(message['data']);
          }
          break;
          
        case 'mutation_response':
        case 'query_response':
          if (_pendingRequests.containsKey(id)) {
            if (message['error'] != null) {
              _pendingRequests[id]?.completeError(message['error']);
            } else {
              _pendingRequests[id]?.complete(message['data']);
            }
            _pendingRequests.remove(id);
          }
          break;
          
        case 'error':
          AppLogger.e('❌ Convex server error: ${message['error']}');
          if (_pendingRequests.containsKey(id)) {
            _pendingRequests[id]?.completeError(message['error']);
            _pendingRequests.remove(id);
          }
          break;
          
        case 'pong':
          AppLogger.d('❤️ Received pong from server');
          break;
          
        case 'welcome':
        case 'connection_established':
          AppLogger.d('✅ Connection established with Convex server');
          break;
          
        default:
          AppLogger.d('❓ Unknown message type: $type - Full message: $data');
      }
    } catch (e, stackTrace) {
      AppLogger.e('❌ Failed to handle WebSocket message', e, stackTrace);
    }
  }

  // Handle WebSocket errors
  void _handleError(error) {
    AppLogger.e('❌ WebSocket error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  // Handle WebSocket disconnection
  void _handleDone() {
    AppLogger.w('⚠️ WebSocket disconnected');
    _isConnected = false;
    _scheduleReconnect();
  }

  // Schedule reconnection
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      AppLogger.d('Attempting to reconnect...');
      connect();
    });
  }

  // Start ping timer for keeping connection alive
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isConnected) {
        _sendMessage({'type': 'ping'});
      }
    });
  }

  // Cancel all timers
  void _cancelTimers() {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
  }

  // Clear all subscriptions
  void _clearSubscriptions() {
    for (final controller in _subscriptions.values) {
      controller.close();
    }
    _subscriptions.clear();
  }

  // HTTP POST helper (fallback)
  Future<Map<String, dynamic>> _httpPost(String endpoint, Map<String, dynamic> body) async {
    // This would use Dio or http package to make HTTP requests
    // Implementation depends on your HTTP client preference
    throw UnimplementedError('HTTP fallback not implemented');
  }

  // Test connection method
  static Future<bool> testConnection() async {
    try {
      final wsUrl = _convexUrl;
      AppLogger.d('Testing connection to: $wsUrl');
      
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Try to listen for a brief moment
      final subscription = channel.stream.timeout(
        const Duration(seconds: 5),
        onTimeout: (sink) {
          AppLogger.w('Connection test timed out');
          sink.close();
        },
      ).listen(
        (data) {
          AppLogger.d('Received test data: ${data.toString().substring(0, 100)}...');
        },
        onError: (error) {
          AppLogger.e('Test connection error: $error');
        },
        onDone: () {
          AppLogger.d('Test connection closed');
        },
      );
      
      await Future.delayed(const Duration(seconds: 2));
      
      // Close the test connection
      subscription.cancel();
      channel.sink.close();
      
      AppLogger.d('✅ Connection test completed');
      return true;
    } catch (e, stackTrace) {
      AppLogger.e('❌ Connection test failed', e, stackTrace);
      return false;
    }
  }
}

// Convex function helpers
class ConvexFunctions {
  static final ConvexService _convex = ConvexService();

  // User functions
  static Future<dynamic> upsertUser({
    required String clerkId,
    required String name,
    required String email,
    String? avatar,
  }) {
    return _convex.mutation('users:upsertUser', {
      'clerkId': clerkId,
      'name': name,
      'email': email,
      if (avatar != null) 'avatar': avatar,
    });
  }

  static Future<dynamic> getUserByClerkId(String clerkId) {
    return _convex.query('users:getUserByClerkId', {'clerkId': clerkId});
  }

  // Conversation functions
  static Future<dynamic> createOrGetConversation({
    required String sellerId,
    required String buyerId,
    required String itemId,
    required String itemTitle,
    required double itemPrice,
    String? itemImage,
  }) {
    return _convex.mutation('conversations:createOrGetConversation', {
      'sellerId': sellerId,
      'buyerId': buyerId,
      'itemId': itemId,
      'itemTitle': itemTitle,
      'itemPrice': itemPrice,
      if (itemImage != null) 'itemImage': itemImage,
    });
  }

  static Stream<dynamic> subscribeToUserConversations(String userId) {
    return _convex.subscribe('conversations:getUserConversations', {'userId': userId});
  }

  static Future<dynamic> getUserConversations(String userId) {
    return _convex.query('conversations:getUserConversations', {'userId': userId});
  }

  static Future<dynamic> getConversation(String conversationId) {
    return _convex.query('conversations:getConversation', {'conversationId': conversationId});
  }

  // Message functions
  static Future<dynamic> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    String type = 'text',
    Map<String, dynamic>? metadata,
  }) {
    return _convex.mutation('messages:sendMessage', {
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'type': type,
      if (metadata != null) 'metadata': metadata,
    });
  }

  static Stream<dynamic> subscribeToMessages(String conversationId) {
    return _convex.subscribe('messages:getMessages', {'conversationId': conversationId});
  }

  static Future<dynamic> getMessages(String conversationId, {int limit = 50}) {
    return _convex.query('messages:getMessages', {
      'conversationId': conversationId,
      'limit': limit,
    });
  }

  static Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) {
    return _convex.mutation('messages:markMessagesAsRead', {
      'conversationId': conversationId,
      'userId': userId,
    });
  }

  static Future<dynamic> getUnreadCount(String userId) {
    return _convex.query('messages:getUnreadCount', {'userId': userId});
  }

  // Typing indicators
  static Future<void> setTyping({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) {
    return _convex.mutation('messages:setTyping', {
      'conversationId': conversationId,
      'userId': userId,
      'isTyping': isTyping,
    });
  }

  static Stream<dynamic> subscribeToTypingUsers({
    required String conversationId,
    required String currentUserId,
  }) {
    return _convex.subscribe('messages:getTypingUsers', {
      'conversationId': conversationId,
      'currentUserId': currentUserId,
    });
  }
}