import 'package:json_annotation/json_annotation.dart';

part 'typing_indicator.g.dart';

@JsonSerializable()
class TypingIndicator {
  final String conversationId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final bool isTyping;
  final DateTime lastUpdate;

  const TypingIndicator({
    required this.conversationId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.isTyping,
    required this.lastUpdate,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) => _$TypingIndicatorFromJson(json);
  Map<String, dynamic> toJson() => _$TypingIndicatorToJson(this);

  bool get isStale {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    return difference.inMinutes > 5; // Consider stale after 5 minutes
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TypingIndicator && 
           other.conversationId == conversationId && 
           other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(conversationId, userId);
}