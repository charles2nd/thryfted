// Simplified User model without JSON serialization for now
class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfile? profile;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatar,
    this.phone,
    this.dateOfBirth,
    this.gender,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatar: json['avatar'],
      phone: json['phone'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      gender: json['gender'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      profile: json['profile'] != null ? UserProfile.fromJson(json['profile']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'phone': phone,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profile': profile?.toJson(),
    };
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) {
      return firstName!;
    }
    return email.split('@').first;
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    if (firstName != null) {
      return firstName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? profile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profile: profile ?? this.profile,
    );
  }
}

class UserProfile {
  final String? bio;
  final String? location;
  final String? website;
  final List<String> interests;
  final UserStats stats;

  UserProfile({
    this.bio,
    this.location,
    this.website,
    required this.interests,
    required this.stats,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      interests: List<String>.from(json['interests'] ?? []),
      stats: UserStats.fromJson(json['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'location': location,
      'website': website,
      'interests': interests,
      'stats': stats.toJson(),
    };
  }
}

class UserStats {
  final int itemsSold;
  final int itemsBought;
  final int followers;
  final int following;
  final double rating;
  final int reviewCount;

  UserStats({
    required this.itemsSold,
    required this.itemsBought,
    required this.followers,
    required this.following,
    required this.rating,
    required this.reviewCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      itemsSold: json['itemsSold'] ?? 0,
      itemsBought: json['itemsBought'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemsSold': itemsSold,
      'itemsBought': itemsBought,
      'followers': followers,
      'following': following,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}