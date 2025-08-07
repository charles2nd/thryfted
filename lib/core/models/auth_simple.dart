// Simplified Auth models without JSON serialization for now
import 'user_simple.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;
  final DateTime expiresAt;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(const Duration(hours: 24)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      rememberMe: json['rememberMe'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'rememberMe': rememberMe,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final bool acceptTerms;

  RegisterRequest({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    required this.acceptTerms,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      acceptTerms: json['acceptTerms'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'acceptTerms': acceptTerms,
    };
  }
}

class SocialLoginRequest {
  final String provider; // 'google', 'facebook', 'apple'
  final String accessToken;
  final Map<String, dynamic> profile;

  SocialLoginRequest({
    required this.provider,
    required this.accessToken,
    required this.profile,
  });

  factory SocialLoginRequest.fromJson(Map<String, dynamic> json) {
    return SocialLoginRequest(
      provider: json['provider'] ?? '',
      accessToken: json['accessToken'] ?? '',
      profile: Map<String, dynamic>.from(json['profile'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'accessToken': accessToken,
      'profile': profile,
    };
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) {
    return RefreshTokenRequest(refreshToken: json['refreshToken'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken};
  }
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequest(email: json['email'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class ResetPasswordRequest {
  final String token;
  final String newPassword;

  ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequest(
      token: json['token'] ?? '',
      newPassword: json['newPassword'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'newPassword': newPassword,
    };
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      currentPassword: json['currentPassword'] ?? '',
      newPassword: json['newPassword'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }
}

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message';
}