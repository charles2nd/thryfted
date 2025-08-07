import 'package:clerk_flutter/clerk_flutter.dart' as clerk;
import 'user_simple.dart';

/// Enhanced user model that works with both Clerk and existing backend
class ClerkUser extends User {
  final String? clerkId;
  final String? externalId;
  final String? username;
  final List<String> emailAddresses;
  final List<String> phoneNumbers;
  final String? profileImageUrl;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime? lastSignInAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? publicMetadata;
  final Map<String, dynamic>? privateMetadata;
  final Map<String, dynamic>? unsafeMetadata;
  
  // Marketplace-specific fields
  final bool isSellerVerified;
  final double? sellerRating;
  final int totalSales;
  final int totalPurchases;
  final String? preferredPaymentMethod;
  final List<String> socialProviders;

  ClerkUser({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    bool isEmailVerified = false,
    bool isPhoneVerified = false,
    required DateTime createdAt,
    required DateTime updatedAt,
    UserProfile? profile,
    this.clerkId,
    this.externalId,
    this.username,
    this.emailAddresses = const [],
    this.phoneNumbers = const [],
    this.profileImageUrl,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.lastSignInAt,
    this.publicMetadata,
    this.privateMetadata,
    this.unsafeMetadata,
    this.isSellerVerified = false,
    this.sellerRating,
    this.totalSales = 0,
    this.totalPurchases = 0,
    this.preferredPaymentMethod,
    this.socialProviders = const [],
  }) : createdAt = createdAt,
       updatedAt = updatedAt,
       super(
         id: id,
         email: email,
         firstName: firstName,
         lastName: lastName,
         avatar: avatarUrl,
         phone: phone,
         dateOfBirth: dateOfBirth,
         gender: gender,
         isEmailVerified: isEmailVerified,
         isPhoneVerified: isPhoneVerified,
         createdAt: createdAt,
         updatedAt: updatedAt,
         profile: profile,
       );

  /// Create ClerkUser from Clerk user object
  factory ClerkUser.fromClerkUser(dynamic clerkUser, {User? existingUser}) {
    final createdAt = clerkUser.createdAt is DateTime ? clerkUser.createdAt : 
                     (clerkUser.createdAt != null ? DateTime.parse(clerkUser.createdAt.toString()) : DateTime.now());
    final updatedAt = clerkUser.updatedAt is DateTime ? clerkUser.updatedAt : 
                     (clerkUser.updatedAt != null ? DateTime.parse(clerkUser.updatedAt.toString()) : DateTime.now());
    
    // Safely get email and phone information
    final emailAddresses = clerkUser.emailAddresses as List<dynamic>?;
    final phoneNumbers = clerkUser.phoneNumbers as List<dynamic>?;
    final firstEmail = emailAddresses?.isNotEmpty == true ? emailAddresses!.first : null;
    final firstPhone = phoneNumbers?.isNotEmpty == true ? phoneNumbers!.first : null;
    
    return ClerkUser(
      id: existingUser?.id ?? clerkUser.id ?? '',
      email: firstEmail?.emailAddress ?? clerkUser.primaryEmailAddress ?? clerkUser.emailAddress ?? '',
      firstName: clerkUser.firstName,
      lastName: clerkUser.lastName,
      avatarUrl: clerkUser.imageUrl ?? clerkUser.profileImageUrl,
      phone: firstPhone?.phoneNumber,
      isEmailVerified: firstEmail?.verification?.status == 'verified' ?? false,
      isPhoneVerified: firstPhone?.verification?.status == 'verified' ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt,
      profile: existingUser?.profile,
      clerkId: clerkUser.id ?? '',
      externalId: null, // Will be populated based on actual API
      username: clerkUser.username,
      emailAddresses: emailAddresses
          ?.map<String>((e) => e.emailAddress ?? '')
          .where((e) => e.isNotEmpty)
          .toList() ?? [],
      phoneNumbers: phoneNumbers
          ?.map<String>((p) => p.phoneNumber ?? '')
          .where((p) => p.isNotEmpty)
          .toList() ?? [],
      profileImageUrl: clerkUser.imageUrl ?? clerkUser.profileImageUrl,
      emailVerified: firstEmail?.verification?.status == 'verified' ?? false,
      phoneVerified: firstPhone?.verification?.status == 'verified' ?? false,
      lastSignInAt: clerkUser.lastSignInAt is DateTime ? clerkUser.lastSignInAt : 
                    (clerkUser.lastSignInAt != null ? DateTime.parse(clerkUser.lastSignInAt.toString()) : null),
      publicMetadata: clerkUser.publicMetadata?.cast<String, dynamic>() ?? {},
      privateMetadata: clerkUser.privateMetadata?.cast<String, dynamic>() ?? {},
      unsafeMetadata: clerkUser.unsafeMetadata?.cast<String, dynamic>() ?? {},
      socialProviders: [], // Will be populated based on actual external accounts
      // Marketplace defaults
      isSellerVerified: existingUser != null ? 
        (existingUser as ClerkUser?)?.isSellerVerified ?? false : false,
      sellerRating: existingUser != null ? 
        (existingUser as ClerkUser?)?.sellerRating : null,
      totalSales: existingUser != null ? 
        (existingUser as ClerkUser?)?.totalSales ?? 0 : 0,
      totalPurchases: existingUser != null ? 
        (existingUser as ClerkUser?)?.totalPurchases ?? 0 : 0,
      preferredPaymentMethod: existingUser != null ? 
        (existingUser as ClerkUser?)?.preferredPaymentMethod : null,
    );
  }

  /// Create from JSON with Clerk data
  factory ClerkUser.fromJson(Map<String, dynamic> json) {
    return ClerkUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatarUrl: json['avatarUrl'] ?? json['profileImageUrl'],
      phone: json['phone'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      gender: json['gender'],
      isEmailVerified: json['isEmailVerified'] ?? json['emailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? json['phoneVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      profile: json['profile'] != null ? UserProfile.fromJson(json['profile']) : null,
      clerkId: json['clerkId'],
      externalId: json['externalId'],
      username: json['username'],
      emailAddresses: List<String>.from(json['emailAddresses'] ?? []),
      phoneNumbers: List<String>.from(json['phoneNumbers'] ?? []),
      profileImageUrl: json['profileImageUrl'],
      emailVerified: json['emailVerified'] ?? false,
      phoneVerified: json['phoneVerified'] ?? false,
      lastSignInAt: json['lastSignInAt'] != null 
        ? DateTime.parse(json['lastSignInAt'])
        : null,
      publicMetadata: json['publicMetadata']?.cast<String, dynamic>(),
      privateMetadata: json['privateMetadata']?.cast<String, dynamic>(),
      unsafeMetadata: json['unsafeMetadata']?.cast<String, dynamic>(),
      isSellerVerified: json['isSellerVerified'] ?? false,
      sellerRating: json['sellerRating']?.toDouble(),
      totalSales: json['totalSales'] ?? 0,
      totalPurchases: json['totalPurchases'] ?? 0,
      preferredPaymentMethod: json['preferredPaymentMethod'],
      socialProviders: List<String>.from(json['socialProviders'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'clerkId': clerkId,
      'externalId': externalId,
      'username': username,
      'emailAddresses': emailAddresses,
      'phoneNumbers': phoneNumbers,
      'profileImageUrl': profileImageUrl,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'lastSignInAt': lastSignInAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'publicMetadata': publicMetadata,
      'privateMetadata': privateMetadata,
      'unsafeMetadata': unsafeMetadata,
      'isSellerVerified': isSellerVerified,
      'sellerRating': sellerRating,
      'totalSales': totalSales,
      'totalPurchases': totalPurchases,
      'preferredPaymentMethod': preferredPaymentMethod,
      'socialProviders': socialProviders,
    });
    return json;
  }

  @override
  ClerkUser copyWith({
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
    // ClerkUser specific fields
    String? clerkId,
    String? externalId,
    String? username,
    List<String>? emailAddresses,
    List<String>? phoneNumbers,
    String? profileImageUrl,
    bool? emailVerified,
    bool? phoneVerified,
    DateTime? lastSignInAt,
    Map<String, dynamic>? publicMetadata,
    Map<String, dynamic>? privateMetadata,
    Map<String, dynamic>? unsafeMetadata,
    bool? isSellerVerified,
    double? sellerRating,
    int? totalSales,
    int? totalPurchases,
    String? preferredPaymentMethod,
    List<String>? socialProviders,
  }) {
    return ClerkUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatar ?? this.profileImageUrl,
      phone: phone ?? (this.phoneNumbers.isNotEmpty ? this.phoneNumbers.first : null),
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      isEmailVerified: isEmailVerified ?? this.emailVerified,
      isPhoneVerified: isPhoneVerified ?? this.phoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profile: profile ?? this.profile,
      // ClerkUser specific fields
      clerkId: clerkId ?? this.clerkId,
      externalId: externalId ?? this.externalId,
      username: username ?? this.username,
      emailAddresses: emailAddresses ?? this.emailAddresses,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      publicMetadata: publicMetadata ?? this.publicMetadata,
      privateMetadata: privateMetadata ?? this.privateMetadata,
      unsafeMetadata: unsafeMetadata ?? this.unsafeMetadata,
      isSellerVerified: isSellerVerified ?? this.isSellerVerified,
      sellerRating: sellerRating ?? this.sellerRating,
      totalSales: totalSales ?? this.totalSales,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      preferredPaymentMethod: preferredPaymentMethod ?? this.preferredPaymentMethod,
      socialProviders: socialProviders ?? this.socialProviders,
    );
  }

  /// Get display name prioritizing first + last name, then username, then email
  @override
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    if (username != null && username!.isNotEmpty) return username!;
    return email.split('@').first;
  }

  /// Get primary email address
  String get primaryEmail => email;

  /// Get primary phone number
  String? get primaryPhone => phoneNumbers.isNotEmpty ? phoneNumbers.first : null;

  /// Check if user has completed profile setup
  bool get isProfileComplete {
    return firstName != null && 
           lastName != null && 
           email.isNotEmpty &&
           emailVerified;
  }

  /// Check if user is verified for selling
  bool get canSell => isSellerVerified && isProfileComplete;

  /// Get seller rating as formatted string
  String get sellerRatingDisplay {
    if (sellerRating == null) return 'No rating';
    return '${sellerRating!.toStringAsFixed(1)} ⭐';
  }

  /// Check if user has social provider connected
  bool hasSocialProvider(String provider) {
    return socialProviders.contains(provider);
  }

  /// Get all verification status
  Map<String, bool> get verificationStatus {
    return {
      'email': emailVerified,
      'phone': phoneVerified,
      'seller': isSellerVerified,
      'profile': isProfileComplete,
    };
  }
  
  /// Get initials for avatar display
  String get initials {
    final first = firstName?.isNotEmpty == true ? firstName![0].toUpperCase() : '';
    final last = lastName?.isNotEmpty == true ? lastName![0].toUpperCase() : '';
    if (first.isNotEmpty && last.isNotEmpty) return first + last;
    if (first.isNotEmpty) return first;
    if (last.isNotEmpty) return last;
    return email.isNotEmpty ? email[0].toUpperCase() : 'U';
  }
}