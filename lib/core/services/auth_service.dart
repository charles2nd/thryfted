import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../models/auth_simple.dart';
import '../models/user_simple.dart';
import '../utils/logger.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  User? _currentUser;
  String? _accessToken;
  String? _refreshToken;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && _accessToken != null;

  Future<void> initialize() async {
    try {
      // Load stored tokens and user data
      _accessToken = await _secureStorage.read(key: AppConstants.accessTokenKey);
      _refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
      
      final userDataString = await _secureStorage.read(key: AppConstants.userDataKey);
      if (userDataString != null) {
        final userData = User.fromJson(
          Map<String, dynamic>.from(
            // Parse the JSON string to Map
            // This is a simplified version - you might want to use a proper JSON parser
            {},
          ),
        );
        _currentUser = userData;
      }

      // Validate token if available
      if (_accessToken != null) {
        await _validateCurrentToken();
      }
    } catch (e) {
      AppLogger.e('Error initializing auth service: $e');
      await _clearAuthData();
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      AppLogger.d('Attempting login for email: ${request.email}');
      
      final response = await _apiService.post(
        Endpoints.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _saveAuthData(authResponse);
        return authResponse;
      } else {
        throw AuthException('Login failed: Invalid response');
      }
    } catch (e) {
      AppLogger.e('Login error: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      AppLogger.d('Attempting registration for email: ${request.email}');
      
      final response = await _apiService.post(
        Endpoints.register,
        data: request.toJson(),
      );

      if (response.statusCode == 201 && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _saveAuthData(authResponse);
        return authResponse;
      } else {
        throw AuthException('Registration failed: Invalid response');
      }
    } catch (e) {
      AppLogger.e('Registration error: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  Future<AuthResponse> socialLogin(SocialLoginRequest request) async {
    try {
      AppLogger.d('Attempting social login with provider: ${request.provider}');
      
      final response = await _apiService.post(
        '${Endpoints.socialLogin}/${request.provider}',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _saveAuthData(authResponse);
        return authResponse;
      } else {
        throw AuthException('Social login failed: Invalid response');
      }
    } catch (e) {
      AppLogger.e('Social login error: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Social login failed: ${e.toString()}');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _apiService.post(
        Endpoints.forgotPassword,
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw AuthException('Password reset request failed');
      }
    } catch (e) {
      AppLogger.e('Forgot password error: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _apiService.post(
        Endpoints.resetPassword,
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw AuthException('Password reset failed');
      }
    } catch (e) {
      AppLogger.e('Reset password error: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      final response = await _apiService.post(
        Endpoints.changePassword,
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw AuthException('Password change failed');
      }
    } catch (e) {
      AppLogger.e('Change password error: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Password change failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      if (_refreshToken != null) {
        await _apiService.post(Endpoints.logout);
      }
    } catch (e) {
      AppLogger.e('Logout error: $e');
    } finally {
      await _clearAuthData();
    }
  }

  Future<User?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    if (_accessToken == null) {
      return null;
    }

    try {
      final response = await _apiService.get('/auth/me');
      if (response.statusCode == 200 && response.data != null) {
        _currentUser = User.fromJson(response.data['data']['user']);
        await _saveUserData(_currentUser!);
        return _currentUser;
      }
    } catch (e) {
      AppLogger.e('Get current user error: $e');
      await _clearAuthData();
    }
    return null;
  }

  Future<void> _validateCurrentToken() async {
    try {
      final response = await _apiService.get('/auth/me');
      if (response.statusCode == 200 && response.data != null) {
        _currentUser = User.fromJson(response.data['data']['user']);
        await _saveUserData(_currentUser!);
      } else {
        await _clearAuthData();
      }
    } catch (e) {
      AppLogger.e('Token validation error: $e');
      await _clearAuthData();
    }
  }

  Future<void> _saveAuthData(AuthResponse authResponse) async {
    _currentUser = authResponse.user;
    _accessToken = authResponse.accessToken;
    _refreshToken = authResponse.refreshToken;

    await Future.wait([
      _secureStorage.write(key: AppConstants.accessTokenKey, value: _accessToken),
      _secureStorage.write(key: AppConstants.refreshTokenKey, value: _refreshToken),
      _saveUserData(_currentUser!),
    ]);

    AppLogger.d('Auth data saved successfully');
  }

  Future<void> _saveUserData(User user) async {
    await _secureStorage.write(
      key: AppConstants.userDataKey,
      value: user.toJson().toString(), // Simplified JSON serialization
    );
  }

  Future<void> _clearAuthData() async {
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;

    await Future.wait([
      _secureStorage.delete(key: AppConstants.accessTokenKey),
      _secureStorage.delete(key: AppConstants.refreshTokenKey),
      _secureStorage.delete(key: AppConstants.userDataKey),
    ]);

    AppLogger.d('Auth data cleared');
  }

  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;

    try {
      final request = RefreshTokenRequest(refreshToken: _refreshToken!);
      final response = await _apiService.post(
        Endpoints.refreshToken,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _saveAuthData(authResponse);
        return true;
      }
    } catch (e) {
      AppLogger.e('Token refresh error: $e');
      await _clearAuthData();
    }
    return false;
  }
}