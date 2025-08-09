// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
      id: json['id'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      itemId: json['itemId'] as String?,
      itemTitle: json['itemTitle'] as String?,
      itemPrice: (json['itemPrice'] as num?)?.toDouble(),
      itemImageUrl: json['itemImageUrl'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
      unreadCount: Map<String, int>.from(json['unreadCount'] as Map),
      isActive: json['isActive'] as bool,
      conversationType:
          $enumDecode(_$ConversationTypeEnumMap, json['conversationType']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      otherParticipants: (json['otherParticipants'] as List<dynamic>?)
          ?.map((e) => UserSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastMessageDetails: json['lastMessageDetails'] == null
          ? null
          : MessageDetails.fromJson(
              json['lastMessageDetails'] as Map<String, dynamic>),
      currentUserUnreadCount: (json['currentUserUnreadCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'participants': instance.participants,
      'itemId': instance.itemId,
      'itemTitle': instance.itemTitle,
      'itemPrice': instance.itemPrice,
      'itemImageUrl': instance.itemImageUrl,
      'lastMessage': instance.lastMessage,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'lastMessageSenderId': instance.lastMessageSenderId,
      'unreadCount': instance.unreadCount,
      'isActive': instance.isActive,
      'conversationType': _$ConversationTypeEnumMap[instance.conversationType]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'otherParticipants': instance.otherParticipants,
      'lastMessageDetails': instance.lastMessageDetails,
      'currentUserUnreadCount': instance.currentUserUnreadCount,
    };

const _$ConversationTypeEnumMap = {
  ConversationType.buyerSeller: 'buyer_seller',
  ConversationType.general: 'general',
};

MessageDetails _$MessageDetailsFromJson(Map<String, dynamic> json) =>
    MessageDetails(
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$MessageDetailsToJson(MessageDetails instance) =>
    <String, dynamic>{
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
    };
