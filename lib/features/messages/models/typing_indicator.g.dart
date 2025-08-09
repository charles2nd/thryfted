// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typing_indicator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TypingIndicator _$TypingIndicatorFromJson(Map<String, dynamic> json) =>
    TypingIndicator(
      conversationId: json['conversationId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      isTyping: json['isTyping'] as bool,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$TypingIndicatorToJson(TypingIndicator instance) =>
    <String, dynamic>{
      'conversationId': instance.conversationId,
      'userId': instance.userId,
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
      'isTyping': instance.isTyping,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
    };
