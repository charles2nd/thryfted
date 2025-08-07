import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/auth_simple.dart';
import '../../../core/models/user_simple.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/auth/clerk_providers.dart';
import '../../../core/auth/migration_service.dart';
import '../../../core/config/clerk_config.dart';
import '../../../core/utils/logger.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});

// Unified Current User Provider (Clerk takes priority)
final unifiedCurrentUserProvider = Provider<User?>((ref) {
  // Priority: Clerk user > Legacy user
  final clerkUser = ref.watch(currentUserProvider);
  if (clerkUser != null) return clerkUser;
  
  final legacyAuthService = ref.watch(authServiceProvider);
  return legacyAuthService.currentUser;
});

// Unified Authentication Provider (either Clerk or Legacy)
final unifiedIsAuthenticatedProvider = Provider<bool>((ref) {
  final isClerkAuth = ref.watch(isAuthenticatedProvider);
  if (isClerkAuth) return true;
  
  final legacyAuthService = ref.watch(authServiceProvider);
  return legacyAuthService.isAuthenticated;
});

// Unified auth loading provider
final unifiedAuthLoadingProvider = Provider<bool>((ref) {
  final clerkLoading = ref.watch(authLoadingProvider);
  final legacyLoading = ref.watch(authStateProvider) == AuthState.loading;
  return clerkLoading || legacyLoading;
});

// Unified error provider
final unifiedAuthErrorProvider = Provider<String?>((ref) {
  final clerkError = ref.watch(authErrorProvider);
  final legacyError = ref.watch(authErrorProvider);
  return clerkError ?? legacyError;
});

// Migration Status Provider
final migrationStatusProvider = FutureProvider<MigrationStatus>((ref) async {
  final migrationService = AuthMigrationService();
  return await migrationService.getMigrationStatus();
});

// Unified Auth Notifier Provider - Simplified for now
final unifiedAuthNotifierProvider = StateProvider<UnifiedAuthState>((ref) {
  return const UnifiedAuthState();
});

// Legacy providers (maintained for backward compatibility)
final currentUserProvider_Legacy = Provider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});

final isAuthenticatedProvider_Legacy = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isAuthenticated;
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(AuthState.initial) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      state = AuthState.loading;
      await _authService.initialize();
      
      if (_authService.isAuthenticated) {
        state = AuthState.authenticated;
      } else {
        state = AuthState.unauthenticated;
      }
    } catch (e) {
      AppLogger.e('Auth initialization error: $e');
      state = AuthState.unauthenticated;
    }
  }

  Future<void> login(String email, String password, {bool rememberMe = false}) async {
    try {
      state = AuthState.loading;
      
      final request = LoginRequest(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      
      await _authService.login(request);
      state = AuthState.authenticated;
      
      AppLogger.d('Login successful for user: ${_authService.currentUser?.email}');
    } catch (e) {
      AppLogger.e('Login failed: $e');
      state = AuthState.error;
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    required bool acceptTerms,
  }) async {
    try {
      state = AuthState.loading;
      
      final request = RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        acceptTerms: acceptTerms,
      );
      
      await _authService.register(request);
      state = AuthState.authenticated;
      
      AppLogger.d('Registration successful for user: ${_authService.currentUser?.email}');
    } catch (e) {
      AppLogger.e('Registration failed: $e');
      state = AuthState.error;
      rethrow;
    }
  }

  Future<void> socialLogin({
    required String provider,
    required String accessToken,
    required Map<String, dynamic> profile,
  }) async {
    try {
      state = AuthState.loading;
      
      final request = SocialLoginRequest(
        provider: provider,
        accessToken: accessToken,
        profile: profile,
      );
      
      await _authService.socialLogin(request);
      state = AuthState.authenticated;
      
      AppLogger.d('Social login successful with $provider');
    } catch (e) {
      AppLogger.e('Social login failed: $e');
      state = AuthState.error;
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _authService.forgotPassword(email);
      AppLogger.d('Password reset email sent to: $email');
    } catch (e) {
      AppLogger.e('Forgot password failed: $e');
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final request = ResetPasswordRequest(
        token: token,
        newPassword: newPassword,
      );
      
      await _authService.resetPassword(request);
      AppLogger.d('Password reset successful');
    } catch (e) {
      AppLogger.e('Reset password failed: $e');
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      await _authService.changePassword(request);
      AppLogger.d('Password change successful');
    } catch (e) {
      AppLogger.e('Change password failed: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      state = AuthState.loading;
      await _authService.logout();
      state = AuthState.unauthenticated;
      
      AppLogger.d('Logout successful');
    } catch (e) {
      AppLogger.e('Logout error: $e');
      state = AuthState.unauthenticated;
    }
  }

  Future<void> refreshToken() async {
    try {
      final success = await _authService.refreshToken();
      if (!success) {
        state = AuthState.unauthenticated;
      }
    } catch (e) {
      AppLogger.e('Token refresh failed: $e');
      state = AuthState.unauthenticated;
    }
  }

  void resetState() {
    state = AuthState.initial;
  }
}

// Loading state provider for specific operations
final authLoadingProvider = StateProvider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState == AuthState.loading;
});

// Error state provider
final authErrorProvider = StateProvider<String?>((ref) {
  return null;
});

/// Unified authentication state that combines Clerk and Legacy auth
class UnifiedAuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final AuthProvider activeProvider; // Which auth system is currently active

  const UnifiedAuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.activeProvider = AuthProvider.none,
  });

  UnifiedAuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    AuthProvider? activeProvider,
  }) {
    return UnifiedAuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeProvider: activeProvider ?? this.activeProvider,
    );
  }
}

/// Enum to track which auth provider is currently active
enum AuthProvider {
  none,
  clerk,
  legacy,
}

