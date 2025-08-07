import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

import 'clerk_service.dart';
import '../models/clerk_user.dart';
import '../utils/logger.dart';

// Core Clerk Service Provider
final clerkServiceProvider = Provider<ClerkService>((ref) {
  return ClerkService();
});

/// Helper class to get Clerk data from context
class ClerkDataHelper {
  static ClerkUser? getCurrentUser(BuildContext context) {
    try {
      return ClerkService.getCurrentUser(context);
    } catch (e) {
      AppLogger.e('Error getting current user from Clerk: $e');
      return null;
    }
  }
  
  static bool isAuthenticated(BuildContext context) {
    try {
      return ClerkService.isAuthenticated(context);
    } catch (e) {
      AppLogger.e('Error checking auth status: $e');
      return false;
    }
  }
  
  static String? getSessionToken(BuildContext context) {
    try {
      return ClerkService.getSessionToken(context);
    } catch (e) {
      AppLogger.e('Error getting session token: $e');
      return null;
    }
  }
}

// Simple providers that don't depend on context (for backward compatibility)
final authLoadingProvider = Provider<bool>((ref) {
  return false; // Clerk handles loading internally
});

final authErrorProvider = Provider<String?>((ref) {
  return null; // Clerk handles errors internally
});