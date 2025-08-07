import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

/// Clerk configuration class that manages environment variables and settings
class ClerkConfig {
  static String? _publishableKey;
  static String? _secretKey;
  static bool _isInitialized = false;

  /// Clerk publishable key - safe for client-side use
  static String get publishableKey {
    if (!_isInitialized) {
      throw Exception('ClerkConfig not initialized. Call initialize() first.');
    }
    return _publishableKey ?? '';
  }
  
  /// Clerk secret key - backend/server use only
  static String get secretKey {
    if (!_isInitialized) {
      throw Exception('ClerkConfig not initialized. Call initialize() first.');
    }
    return _secretKey ?? '';
  }

  static bool get isConfigured => 
      _publishableKey?.isNotEmpty == true && _secretKey?.isNotEmpty == true;

  static bool get enableClerkAuth => 
      dotenv.env['ENABLE_CLERK_AUTH']?.toLowerCase() == 'true';

  static bool get enableLegacyAuthFallback => 
      dotenv.env['ENABLE_LEGACY_AUTH_FALLBACK']?.toLowerCase() == 'true';

  static bool get enableMigration => 
      dotenv.env['ENABLE_MIGRATION']?.toLowerCase() == 'true';

  static bool get enableSocialLogin => 
      dotenv.env['ENABLE_SOCIAL_LOGIN']?.toLowerCase() == 'true';

  static String get apiBaseUrl => 
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';

  static String get socketUrl => 
      dotenv.env['SOCKET_URL'] ?? 'ws://localhost:8080';

  static bool get debugMode => 
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  static Future<void> initialize() async {
    try {
      if (_isInitialized) {
        AppLogger.w('ClerkConfig already initialized');
        return;
      }

      await dotenv.load();
      
      // Try both formats for Clerk keys
      _publishableKey = dotenv.env['CLERK_PUBLISHABLE_KEY'] ?? 
                       dotenv.env['NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY'];
      _secretKey = dotenv.env['CLERK_SECRET_KEY'];

      _isInitialized = true;

      if (debugMode) {
        AppLogger.d('ClerkConfig initialized successfully');
        AppLogger.d('Publishable key configured: ${_publishableKey?.isNotEmpty == true}');
        AppLogger.d('Secret key configured: ${_secretKey?.isNotEmpty == true}');
        AppLogger.d('Clerk auth enabled: $enableClerkAuth');
        AppLogger.d('Legacy auth fallback: $enableLegacyAuthFallback');
      }

      validateConfig();
    } catch (e) {
      AppLogger.e('Failed to initialize ClerkConfig: $e');
      _isInitialized = true; // Mark as initialized even if failed to prevent repeated attempts
      rethrow;
    }
  }
  
  /// Frontend API base URL for Clerk
  static String get frontendApi {
    // Extract domain from publishable key
    final key = publishableKey;
    if (key.startsWith('pk_test_')) {
      return 'https://api.clerk.dev';
    } else if (key.startsWith('pk_live_')) {
      return 'https://api.clerk.dev';
    }
    return 'https://api.clerk.dev';
  }
  
  /// Sign-in redirect URL after successful authentication
  static const String signInRedirectUrl = '/home';
  
  /// Sign-up redirect URL after successful registration  
  static const String signUpRedirectUrl = '/home';
  
  /// After sign-out redirect URL
  static const String signOutRedirectUrl = '/auth/login';
  
  /// Allowed redirect domains for security
  static const List<String> allowedRedirectOrigins = [
    'http://localhost:3000',
    'https://your-app-domain.com',
  ];
  
  /// Clerk appearance configuration
  static const Map<String, dynamic> appearanceConfig = {
    'theme': {
      'primaryColor': '#6366F1', // Indigo-500
      'borderRadius': '8px',
    },
    'layout': {
      'socialButtonsPlacement': 'top',
      'logoPlacement': 'inside',
    },
    'variables': {
      'colorPrimary': '#6366F1',
      'colorDanger': '#EF4444',
      'colorSuccess': '#10B981',
      'colorWarning': '#F59E0B',
      'colorNeutral': '#6B7280',
    },
  };
  
  /// Session token lifetime (24 hours by default)
  static const Duration sessionLifetime = Duration(hours: 24);
  
  /// Refresh threshold (refresh token when 10 minutes remain)
  static const Duration refreshThreshold = Duration(minutes: 10);
  
  /// Enable multi-factor authentication
  static const bool enableMfa = true;
  
  /// Enable social sign-in providers
  static const List<String> enabledSocialProviders = [
    'google',
    'facebook', 
    'apple',
    // 'github', // Optional for marketplace
    // 'discord', // Optional
  ];
  
  /// Enable email verification
  static const bool requireEmailVerification = true;
  
  /// Enable phone verification  
  static const bool enablePhoneVerification = false;
  
  /// Validate configuration
  static void validateConfig() {
    final issues = <String>[];

    if (_publishableKey?.isEmpty != false) {
      issues.add('CLERK_PUBLISHABLE_KEY is missing or empty');
    } else if (!_publishableKey!.startsWith('pk_')) {
      issues.add('CLERK_PUBLISHABLE_KEY should start with "pk_"');
    }

    if (_secretKey?.isEmpty != false) {
      issues.add('CLERK_SECRET_KEY is missing or empty');
    } else if (!_secretKey!.startsWith('sk_')) {
      issues.add('CLERK_SECRET_KEY should start with "sk_"');
    }

    if (enableClerkAuth && !isConfigured) {
      issues.add('Clerk authentication is enabled but keys are not properly configured');
    }

    if (issues.isNotEmpty) {
      AppLogger.w('Clerk configuration issues found:');
      for (final issue in issues) {
        AppLogger.w('- $issue');
      }
      
      if (enableClerkAuth && !enableLegacyAuthFallback) {
        throw Exception(
          'Critical Clerk configuration issues found and no fallback enabled:\n'
          '${issues.join('\n')}',
        );
      }
    } else if (debugMode) {
      AppLogger.d('Clerk configuration validation passed');
    }
  }

  static Map<String, dynamic> toJson() => {
    'isInitialized': _isInitialized,
    'isConfigured': isConfigured,
    'enableClerkAuth': enableClerkAuth,
    'enableLegacyAuthFallback': enableLegacyAuthFallback,
    'enableMigration': enableMigration,
    'enableSocialLogin': enableSocialLogin,
    'apiBaseUrl': apiBaseUrl,
    'debugMode': debugMode,
    'publishableKeyPrefix': _publishableKey?.substring(0, 7) ?? 'not-set',
    'secretKeyPrefix': _secretKey?.substring(0, 7) ?? 'not-set',
  };

  static void reset() {
    _publishableKey = null;
    _secretKey = null;
    _isInitialized = false;
  }
}

/// Environment configuration helper
class EnvConfig {
  static const bool isDevelopment = kDebugMode;
  static const bool isProduction = !kDebugMode;
  
  /// Get environment variable with fallback
  static String getEnvVar(String key, {String fallback = ''}) {
    final value = const String.fromEnvironment('', defaultValue: '');
    return value.isEmpty ? fallback : value;
  }
}