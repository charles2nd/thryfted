import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';

import '../config/clerk_config.dart';
import '../models/clerk_user.dart';
import '../utils/logger.dart';

/// Simplified Clerk service that works with the actual Clerk Flutter SDK
class ClerkService {
  static final ClerkService _instance = ClerkService._internal();
  factory ClerkService() => _instance;
  ClerkService._internal();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Initialize Clerk service
  Future<void> initialize() async {
    try {
      AppLogger.d('🔧 Initializing Clerk service...');
      
      // Validate configuration
      ClerkConfig.validateConfig();
      
      _isInitialized = true;
      AppLogger.d('✅ Clerk service initialized successfully');
      
    } catch (e) {
      AppLogger.e('❌ Failed to initialize Clerk service: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Get current user from Clerk context
  static ClerkUser? getCurrentUser(BuildContext context) {
    try {
      // First check if user is actually authenticated
      if (!isAuthenticated(context)) {
        return null;
      }
      
      final user = ClerkAuth.userOf(context);
      if (user != null) {
        return ClerkUser.fromClerkUser(user);
      }
      return null;
    } catch (e) {
      AppLogger.e('Error getting current user: $e');
      return null;
    }
  }

  /// Check if user is authenticated
  static bool isAuthenticated(BuildContext context) {
    try {
      final authState = ClerkAuth.of(context);
      return authState.user != null;
    } catch (e) {
      AppLogger.e('Error checking auth status: $e');
      return false;
    }
  }

  /// Get session token
  static String? getSessionToken(BuildContext context) {
    try {
      final session = ClerkAuth.sessionOf(context);
      return session?.id;
    } catch (e) {
      AppLogger.e('Error getting session token: $e');
      return null;
    }
  }

  /// Sync user data with backend when user signs in
  /// Note: This will be implemented when backend sync is needed
  static Future<void> syncUserWithBackend(BuildContext context, ClerkUser user) async {
    try {
      AppLogger.d('User sync with backend: ${user.clerkId} (${user.email})');
      // TODO: Implement backend sync when needed
      // This avoids circular dependency with ApiService
    } catch (e) {
      AppLogger.e('Error syncing user with backend: $e');
      // Continue with Clerk data only
    }
  }
}

/// Clerk authentication exceptions
class ClerkAuthException implements Exception {
  final String message;
  final String? code;

  ClerkAuthException(this.message, {this.code});

  @override
  String toString() => 'ClerkAuthException: $message';
}