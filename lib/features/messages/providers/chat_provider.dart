import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/convex_service.dart';
import '../../../core/auth/clerk_providers.dart';

part 'chat_provider.g.dart';

// Current user ID provider
final currentUserIdProvider = Provider<String?>((ref) {
  // This should get the user ID from Clerk auth
  // For now, returning a mock ID
  // TODO: Connect to actual Clerk user
  return 'mock_user_id';
});

// Convex service provider
final convexServiceProvider = Provider<ConvexService>((ref) {
  final service = ConvexService();
  service.connect();
  ref.onDispose(() {
    service.disconnect();
  });
  return service;
});

// Conversations provider
@riverpod
class ConversationsNotifier extends _$ConversationsNotifier {
  @override
  Future<List<dynamic>> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return [];
    
    try {
      return await ConvexFunctions.getUserConversations(userId);
    } catch (e) {
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) return [];
      return await ConvexFunctions.getUserConversations(userId);
    });
  }

  Future<dynamic> createConversation({
    required String sellerId,
    required String buyerId,
    required String itemId,
    required String itemTitle,
    required double itemPrice,
    String? itemImage,
  }) async {
    try {
      final conversationId = await ConvexFunctions.createOrGetConversation(
        sellerId: sellerId,
        buyerId: buyerId,
        itemId: itemId,
        itemTitle: itemTitle,
        itemPrice: itemPrice,
        itemImage: itemImage,
      );
      
      // Refresh conversations list
      await refresh();
      
      return conversationId;
    } catch (e) {
      return null;
    }
  }
}

// Messages provider for a specific conversation
@riverpod
class MessagesNotifier extends _$MessagesNotifier {
  @override
  Stream<dynamic> build(String conversationId) {
    return ConvexFunctions.subscribeToMessages(conversationId);
  }

  Future<void> sendMessage({
    required String content,
    String type = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    await ConvexFunctions.sendMessage(
      conversationId: conversationId,
      senderId: userId,
      content: content,
      type: type,
      metadata: metadata,
    );
  }

  Future<void> markAsRead() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    await ConvexFunctions.markMessagesAsRead(
      conversationId: conversationId,
      userId: userId,
    );
  }
}

// Typing indicator provider
@riverpod
Stream<dynamic> typingUsers(TypingUsersRef ref, String conversationId) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  
  return ConvexFunctions.subscribeToTypingUsers(
    conversationId: conversationId,
    currentUserId: userId,
  );
}

// Unread count provider
@riverpod
Future<dynamic> unreadCount(UnreadCountRef ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 0;
  
  try {
    return await ConvexFunctions.getUnreadCount(userId);
  } catch (e) {
    return 0;
  }
}