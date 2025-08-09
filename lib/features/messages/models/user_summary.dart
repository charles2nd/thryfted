import 'package:json_annotation/json_annotation.dart';

part 'user_summary.g.dart';

@JsonSerializable()
class UserSummary {
  final String id;
  final String name;
  final String? avatar;
  final String? clerkId;
  final bool? isOnline;
  final DateTime? lastSeen;

  const UserSummary({
    required this.id,
    required this.name,
    this.avatar,
    this.clerkId,
    this.isOnline,
    this.lastSeen,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) => _$UserSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$UserSummaryToJson(this);

  String get initials {
    if (name.isEmpty) return 'U';
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  bool get isCurrentlyOnline {
    if (isOnline == true) return true;
    
    if (lastSeen != null) {
      final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
      return lastSeen!.isAfter(fiveMinutesAgo);
    }
    
    return false;
  }

  String get lastSeenText {
    if (isCurrentlyOnline) return 'Online';
    
    if (lastSeen == null) return 'Last seen unknown';
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen!);
    
    if (difference.inMinutes < 60) {
      return 'Last seen ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Last seen ${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return 'Last seen ${difference.inDays}d ago';
    } else {
      return 'Last seen long ago';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSummary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}