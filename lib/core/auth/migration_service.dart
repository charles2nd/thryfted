import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import 'clerk_service.dart';
import '../models/clerk_user.dart';

/// Service to handle migration from legacy JWT auth to Clerk
class AuthMigrationService {
  static final AuthMigrationService _instance = AuthMigrationService._internal();
  factory AuthMigrationService() => _instance;
  AuthMigrationService._internal();

  final AuthService _legacyAuthService = AuthService();
  final ClerkService _clerkService = ClerkService();
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Check if user needs migration from legacy auth to Clerk
  Future<bool> needsMigration() async {
    try {
      // Check if user has legacy JWT token but no Clerk session
      final hasLegacyToken = await _hasLegacyToken();
      final hasClerkSession = false; // Will be updated when Clerk is properly integrated
      
      return hasLegacyToken && !hasClerkSession;
    } catch (e) {
      AppLogger.e('Error checking migration need: $e');
      return false;
    }
  }

  /// Migrate user from legacy auth to Clerk
  Future<ClerkUser?> migrateToClerk() async {
    try {
      AppLogger.d('🔄 Starting auth migration to Clerk...');

      // 1. Verify legacy authentication is valid
      final legacyUser = await _legacyAuthService.getCurrentUser();
      if (legacyUser == null) {
        AppLogger.w('No valid legacy user found for migration');
        return null;
      }

      // 2. Check if user already exists in Clerk
      final existingClerkUser = await _findExistingClerkUser(legacyUser.email);
      if (existingClerkUser != null) {
        AppLogger.d('User already exists in Clerk, linking accounts...');
        return await _linkAccounts(legacyUser, existingClerkUser);
      }

      // 3. Create new Clerk user account
      AppLogger.d('Creating new Clerk account for: ${legacyUser.email}');
      return await _createClerkAccount(legacyUser);

    } catch (e) {
      AppLogger.e('❌ Auth migration failed: $e');
      rethrow;
    }
  }

  /// Gradual migration strategy - run in background
  Future<void> performGradualMigration() async {
    try {
      if (!await needsMigration()) {
        return;
      }

      AppLogger.d('🔄 Performing gradual migration...');

      // 1. Migrate user data to Clerk-compatible format
      await _migrateUserData();

      // 2. Sync marketplace-specific data
      await _syncMarketplaceData();

      // 3. Preserve user preferences
      await _migrateUserPreferences();

      AppLogger.d('✅ Gradual migration completed');
    } catch (e) {
      AppLogger.e('❌ Gradual migration failed: $e');
      // Don't throw - this should be non-blocking
    }
  }

  /// Clean up legacy auth data after successful Clerk migration
  Future<void> cleanupLegacyAuth() async {
    try {
      AppLogger.d('🧹 Cleaning up legacy auth data...');

      // Clear legacy JWT tokens
      await Future.wait([
        _secureStorage.delete(key: AppConstants.accessTokenKey),
        _secureStorage.delete(key: AppConstants.refreshTokenKey),
        _secureStorage.delete(key: AppConstants.userDataKey),
      ]);

      AppLogger.d('✅ Legacy auth cleanup completed');
    } catch (e) {
      AppLogger.e('❌ Legacy auth cleanup failed: $e');
    }
  }

  /// Rollback to legacy auth if Clerk migration fails
  Future<void> rollbackToLegacy() async {
    try {
      AppLogger.d('↩️ Rolling back to legacy auth...');

      // Re-initialize legacy auth service
      await _legacyAuthService.initialize();
      
      // Validate legacy tokens
      if (_legacyAuthService.isAuthenticated) {
        AppLogger.d('✅ Successfully rolled back to legacy auth');
      } else {
        AppLogger.w('⚠️ Legacy auth tokens are invalid, user needs to login again');
      }
    } catch (e) {
      AppLogger.e('❌ Rollback to legacy auth failed: $e');
    }
  }

  /// Check if user has valid legacy tokens
  Future<bool> _hasLegacyToken() async {
    final accessToken = await _secureStorage.read(key: AppConstants.accessTokenKey);
    final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
    return accessToken != null && refreshToken != null;
  }

  /// Find existing Clerk user by email
  Future<ClerkUser?> _findExistingClerkUser(String email) async {
    try {
      // This would typically call your backend API that interfaces with Clerk
      final response = await _apiService.post(
        '/auth/clerk/find-user',
        data: {'email': email},
      );

      if (response.statusCode == 200 && response.data != null) {
        return ClerkUser.fromJson(response.data);
      }
      return null;
    } catch (e) {
      AppLogger.e('Error finding existing Clerk user: $e');
      return null;
    }
  }

  /// Create new Clerk account for legacy user
  Future<ClerkUser> _createClerkAccount(dynamic legacyUser) async {
    try {
      // Generate a temporary password for migration
      final tempPassword = _generateTempPassword();

      // Call backend API to create Clerk user
      final response = await _apiService.post(
        '/auth/clerk/migrate-user',
        data: {
          'legacyUserId': legacyUser.id,
          'email': legacyUser.email,
          'firstName': legacyUser.firstName,
          'lastName': legacyUser.lastName,
          'username': legacyUser.username,
          'tempPassword': tempPassword,
          'metadata': {
            'migratedFrom': 'legacy_jwt',
            'migratedAt': DateTime.now().toIso8601String(),
            'legacyUserId': legacyUser.id,
          },
        },
      );

      if (response.statusCode == 201 && response.data != null) {
        final clerkUser = ClerkUser.fromJson(response.data);
        
        // Store temporary password for user to update
        await _storeMigrationInfo(tempPassword);
        
        return clerkUser;
      } else {
        throw MigrationException('Failed to create Clerk account');
      }
    } catch (e) {
      AppLogger.e('Error creating Clerk account: $e');
      rethrow;
    }
  }

  /// Link legacy account with existing Clerk account
  Future<ClerkUser> _linkAccounts(dynamic legacyUser, ClerkUser clerkUser) async {
    try {
      // Call backend to link accounts
      final response = await _apiService.post(
        '/auth/clerk/link-accounts',
        data: {
          'legacyUserId': legacyUser.id,
          'clerkUserId': clerkUser.clerkId,
          'metadata': {
            'linkedAt': DateTime.now().toIso8601String(),
            'linkMethod': 'migration',
          },
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return ClerkUser.fromJson(response.data);
      } else {
        throw MigrationException('Failed to link accounts');
      }
    } catch (e) {
      AppLogger.e('Error linking accounts: $e');
      rethrow;
    }
  }

  /// Migrate user data to Clerk-compatible format
  Future<void> _migrateUserData() async {
    try {
      final legacyUser = await _legacyAuthService.getCurrentUser();
      if (legacyUser == null) return;

      // Convert legacy user data to Clerk format
      await _apiService.post(
        '/users/migrate-data',
        data: {
          'userId': legacyUser.id,
          'clerkFormat': true,
          'preserveMetadata': true,
        },
      );
    } catch (e) {
      AppLogger.e('Error migrating user data: $e');
    }
  }

  /// Sync marketplace-specific data (ratings, sales, etc.)
  Future<void> _syncMarketplaceData() async {
    try {
      await _apiService.post('/users/sync-marketplace-data');
    } catch (e) {
      AppLogger.e('Error syncing marketplace data: $e');
    }
  }

  /// Migrate user preferences and settings
  Future<void> _migrateUserPreferences() async {
    try {
      // Migrate theme preferences, notification settings, etc.
      final themeMode = await _secureStorage.read(key: AppConstants.themeKey);
      
      if (themeMode != null) {
        await _apiService.post(
          '/users/preferences',
          data: {'themeMode': themeMode},
        );
      }
    } catch (e) {
      AppLogger.e('Error migrating user preferences: $e');
    }
  }

  /// Generate temporary password for migration
  String _generateTempPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return 'Temp${random.substring(random.length - 8)}!';
  }

  /// Store migration info for user reference
  Future<void> _storeMigrationInfo(String tempPassword) async {
    await _secureStorage.write(
      key: 'migration_temp_password',
      value: tempPassword,
    );
    await _secureStorage.write(
      key: 'migration_timestamp',
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Get migration status
  Future<MigrationStatus> getMigrationStatus() async {
    try {
      final hasLegacy = await _hasLegacyToken();
      final hasClerk = false; // Will be updated when Clerk is properly integrated
      final migrationTimestamp = await _secureStorage.read(key: 'migration_timestamp');

      if (hasClerk && migrationTimestamp != null) {
        return MigrationStatus.completed;
      } else if (hasLegacy && !hasClerk) {
        return MigrationStatus.needed;
      } else if (hasClerk && !hasLegacy) {
        return MigrationStatus.notNeeded;
      } else {
        return MigrationStatus.unknown;
      }
    } catch (e) {
      AppLogger.e('Error getting migration status: $e');
      return MigrationStatus.error;
    }
  }

  /// Clear migration temporary data
  Future<void> clearMigrationData() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: 'migration_temp_password'),
        _secureStorage.delete(key: 'migration_timestamp'),
      ]);
    } catch (e) {
      AppLogger.e('Error clearing migration data: $e');
    }
  }
}

/// Migration status enum
enum MigrationStatus {
  needed,      // User has legacy auth but no Clerk
  completed,   // User has been migrated to Clerk
  notNeeded,   // User only has Clerk auth
  unknown,     // Cannot determine status
  error,       // Error checking status
}

/// Migration exception
class MigrationException implements Exception {
  final String message;
  final String? code;

  MigrationException(this.message, {this.code});

  @override
  String toString() => 'MigrationException: $message';
}

/// Migration result data class
class MigrationResult {
  final bool success;
  final ClerkUser? user;
  final String? error;
  final DateTime timestamp;

  MigrationResult({
    required this.success,
    this.user,
    this.error,
    required this.timestamp,
  });

  factory MigrationResult.success(ClerkUser user) {
    return MigrationResult(
      success: true,
      user: user,
      timestamp: DateTime.now(),
    );
  }

  factory MigrationResult.failure(String error) {
    return MigrationResult(
      success: false,
      error: error,
      timestamp: DateTime.now(),
    );
  }
}