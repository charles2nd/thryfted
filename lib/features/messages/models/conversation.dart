import 'package:json_annotation/json_annotation.dart';
import 'user_summary.dart';

part 'conversation.g.dart';

@JsonSerializable()
class Conversation {
  final String id;
  final List<String> participants;
  final String? itemId;
  final String? itemTitle;
  final double? itemPrice;
  final String? itemImageUrl;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final bool isActive;
  final ConversationType conversationType;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional fields populated by Convex queries
  final List<UserSummary>? otherParticipants;
  final MessageDetails? lastMessageDetails;
  final int? currentUserUnreadCount;

  const Conversation({
    required this.id,
    required this.participants,
    this.itemId,
    this.itemTitle,
    this.itemPrice,
    this.itemImageUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
    required this.unreadCount,
    required this.isActive,
    required this.conversationType,
    required this.createdAt,
    required this.updatedAt,
    this.otherParticipants,
    this.lastMessageDetails,
    this.currentUserUnreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  Conversation copyWith({
    String? id,
    List<String>? participants,
    String? itemId,
    String? itemTitle,
    double? itemPrice,
    String? itemImageUrl,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    bool? isActive,
    ConversationType? conversationType,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<UserSummary>? otherParticipants,
    MessageDetails? lastMessageDetails,
    int? currentUserUnreadCount,
  }) {
    return Conversation(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      itemId: itemId ?? this.itemId,
      itemTitle: itemTitle ?? this.itemTitle,
      itemPrice: itemPrice ?? this.itemPrice,
      itemImageUrl: itemImageUrl ?? this.itemImageUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
      conversationType: conversationType ?? this.conversationType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      otherParticipants: otherParticipants ?? this.otherParticipants,
      lastMessageDetails: lastMessageDetails ?? this.lastMessageDetails,
      currentUserUnreadCount: currentUserUnreadCount ?? this.currentUserUnreadCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum ConversationType {
  @JsonValue('buyer_seller')
  buyerSeller,
  @JsonValue('general')
  general,
}

@JsonSerializable()
class MessageDetails {
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;

  const MessageDetails({
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
  });

  factory MessageDetails.fromJson(Map<String, dynamic> json) => _$MessageDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$MessageDetailsToJson(this);
}