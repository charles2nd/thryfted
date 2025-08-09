import 'package:json_annotation/json_annotation.dart';
import 'user_summary.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType messageType;
  final String? imageUrl;
  final double? offerAmount;
  final bool isRead;
  final List<String> readBy;
  final String? replyToMessageId;
  final bool isEdited;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional fields populated by Convex queries
  final UserSummary? sender;
  final List<MessageReaction>? reactions;
  final Message? replyToMessage;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.imageUrl,
    this.offerAmount,
    required this.isRead,
    required this.readBy,
    this.replyToMessageId,
    required this.isEdited,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.reactions,
    this.replyToMessage,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? content,
    MessageType? messageType,
    String? imageUrl,
    double? offerAmount,
    bool? isRead,
    List<String>? readBy,
    String? replyToMessageId,
    bool? isEdited,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserSummary? sender,
    List<MessageReaction>? reactions,
    Message? replyToMessage,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      imageUrl: imageUrl ?? this.imageUrl,
      offerAmount: offerAmount ?? this.offerAmount,
      isRead: isRead ?? this.isRead,
      readBy: readBy ?? this.readBy,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
      reactions: reactions ?? this.reactions,
      replyToMessage: replyToMessage ?? this.replyToMessage,
    );
  }

  bool isOwnMessage(String currentUserId) {
    return senderId == currentUserId;
  }

  bool isReadByUser(String userId) {
    return readBy.contains(userId);
  }

  String get displayContent {
    if (isDeleted) return 'This message was deleted';
    return content;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('system')
  system,
  @JsonValue('offer')
  offer,
}

@JsonSerializable()
class MessageReaction {
  final String emoji;
  final List<ReactionUser> users;
  final int count;

  const MessageReaction({
    required this.emoji,
    required this.users,
    required this.count,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) => _$MessageReactionFromJson(json);
  Map<String, dynamic> toJson() => _$MessageReactionToJson(this);
}

@JsonSerializable()
class ReactionUser {
  final String userId;
  final String userName;
  final String? userAvatar;

  const ReactionUser({
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  factory ReactionUser.fromJson(Map<String, dynamic> json) => _$ReactionUserFromJson(json);
  Map<String, dynamic> toJson() => _$ReactionUserToJson(this);
}

@JsonSerializable()
class SendMessageRequest {
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType messageType;
  final String? imageUrl;
  final double? offerAmount;
  final String? replyToMessageId;

  const SendMessageRequest({
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.messageType = MessageType.text,
    this.imageUrl,
    this.offerAmount,
    this.replyToMessageId,
  });

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) => _$SendMessageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SendMessageRequestToJson(this);
}