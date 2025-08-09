// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      messageType: $enumDecode(_$MessageTypeEnumMap, json['messageType']),
      imageUrl: json['imageUrl'] as String?,
      offerAmount: (json['offerAmount'] as num?)?.toDouble(),
      isRead: json['isRead'] as bool,
      readBy:
          (json['readBy'] as List<dynamic>).map((e) => e as String).toList(),
      replyToMessageId: json['replyToMessageId'] as String?,
      isEdited: json['isEdited'] as bool,
      isDeleted: json['isDeleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      sender: json['sender'] == null
          ? null
          : UserSummary.fromJson(json['sender'] as Map<String, dynamic>),
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      replyToMessage: json['replyToMessage'] == null
          ? null
          : Message.fromJson(json['replyToMessage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'senderId': instance.senderId,
      'content': instance.content,
      'messageType': _$MessageTypeEnumMap[instance.messageType]!,
      'imageUrl': instance.imageUrl,
      'offerAmount': instance.offerAmount,
      'isRead': instance.isRead,
      'readBy': instance.readBy,
      'replyToMessageId': instance.replyToMessageId,
      'isEdited': instance.isEdited,
      'isDeleted': instance.isDeleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'sender': instance.sender,
      'reactions': instance.reactions,
      'replyToMessage': instance.replyToMessage,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.system: 'system',
  MessageType.offer: 'offer',
};

MessageReaction _$MessageReactionFromJson(Map<String, dynamic> json) =>
    MessageReaction(
      emoji: json['emoji'] as String,
      users: (json['users'] as List<dynamic>)
          .map((e) => ReactionUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$MessageReactionToJson(MessageReaction instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'users': instance.users,
      'count': instance.count,
    };

ReactionUser _$ReactionUserFromJson(Map<String, dynamic> json) => ReactionUser(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
    );

Map<String, dynamic> _$ReactionUserToJson(ReactionUser instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
    };

SendMessageRequest _$SendMessageRequestFromJson(Map<String, dynamic> json) =>
    SendMessageRequest(
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      messageType:
          $enumDecodeNullable(_$MessageTypeEnumMap, json['messageType']) ??
              MessageType.text,
      imageUrl: json['imageUrl'] as String?,
      offerAmount: (json['offerAmount'] as num?)?.toDouble(),
      replyToMessageId: json['replyToMessageId'] as String?,
    );

Map<String, dynamic> _$SendMessageRequestToJson(SendMessageRequest instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'senderId': instance.senderId,
      'content': instance.content,
      'messageType': _$MessageTypeEnumMap[instance.messageType]!,
      'imageUrl': instance.imageUrl,
      'offerAmount': instance.offerAmount,
      'replyToMessageId': instance.replyToMessageId,
    };
