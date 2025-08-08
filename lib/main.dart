import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/navigation/app_router.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/auth/clerk_service.dart';
import 'core/auth/auth_wrapper.dart';
import 'core/auth/migration_service.dart';
import 'core/config/clerk_config.dart';
import 'core/providers/language_provider.dart';
import 'shared/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Clerk configuration first
    debugPrint('🔧 Initializing Clerk configuration...');
    await ClerkConfig.initialize();
    debugPrint('✅ Clerk configuration initialized');
    
    // Initialize Firebase (optional - will work without it)
    try {
      // Comment out Firebase for now - uncomment when you have firebase_options.dart
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
      debugPrint('📱 Running without Firebase (add configuration when ready)');
    } catch (e) {
      debugPrint('Firebase initialization skipped: $e');
    }
    
    // Initialize services
    ApiService().initialize();
    
    // Initialize auth systems based on configuration
    if (ClerkConfig.enableLegacyAuthFallback) {
      await AuthService().initialize(); // Legacy auth
      debugPrint('✅ Legacy auth initialized');
    }
    
    if (ClerkConfig.enableClerkAuth && ClerkConfig.isConfigured) {
      await ClerkService().initialize(); // New Clerk auth
      debugPrint('✅ Clerk auth initialized');
    } else {
      debugPrint('⚠️ Clerk auth disabled or not configured');
    }
    
    // Check for migration needs
    if (ClerkConfig.enableMigration) {
      final migrationService = AuthMigrationService();
      if (await migrationService.needsMigration()) {
        debugPrint('🔄 User migration needed - will migrate in background');
        // Perform migration in background (non-blocking)
        migrationService.performGradualMigration().catchError((e) {
          debugPrint('Migration error: $e');
        });
      }
    }
  } catch (e) {
    debugPrint('❌ Initialization error: $e');
    // Continue with basic app startup
  }
  
  runApp(
    const ProviderScope(
      child: ThryfedApp(),
    ),
  );
}

class ThryfedApp extends ConsumerWidget {
  const ThryfedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final router = ref.watch(appRouterProvider);
    
    return ClerkAuthWrapper(
      child: ProviderScope(
        child: ClerkErrorListener(
          child: ClerkAuthBuilder(
            signedInBuilder: (context, authState) {
              // When signed in, use the router for navigation
              return MaterialApp.router(
                routerConfig: router,
                title: 'Thryfted',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: LanguageNotifier.supportedLocales,
                locale: currentLocale,
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    child: child!,
                  );
                },
              );
            },
            signedOutBuilder: (context, authState) {
              // When signed out, show authentication screen
              return MaterialApp(
                title: 'Thryfted',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: LanguageNotifier.supportedLocales,
                locale: currentLocale,
                home: _buildAuthenticationScreen(),
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    child: child!,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _buildAuthenticationScreen() {
    // Use Clerk's built-in authentication UI
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // App branding
                  Text(
                    l10n.welcomeToThryfted,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.appTagline,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Clerk's authentication component
                  const Expanded(
                    child: ClerkAuthentication(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
