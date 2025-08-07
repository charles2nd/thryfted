import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language provider for managing app localization
class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('fr', 'CA')) {
    _loadSavedLanguage();
  }

  static const String _languageKey = 'selected_language';
  
  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('fr', 'CA'), // French Canada (default)
    Locale('en', 'CA'), // English Canada
    Locale('fr'),       // French (fallback)
    Locale('en'),       // English (fallback)
  ];

  /// Load saved language preference
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        // Parse language code (e.g., "fr_CA" or "en_CA")
        final parts = languageCode.split('_');
        final locale = parts.length > 1 
          ? Locale(parts[0], parts[1])
          : Locale(parts[0]);
          
        // Only set if it's a supported locale
        if (supportedLocales.contains(locale)) {
          state = locale;
        }
      }
    } catch (e) {
      // If loading fails, keep default French Canadian
    }
  }

  /// Change app language
  Future<void> changeLanguage(Locale newLocale) async {
    try {
      state = newLocale;
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      final languageCode = newLocale.countryCode != null
        ? '${newLocale.languageCode}_${newLocale.countryCode}'
        : newLocale.languageCode;
      
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Toggle between French and English
  Future<void> toggleLanguage() async {
    final newLocale = state.languageCode == 'fr' 
      ? const Locale('en', 'CA')
      : const Locale('fr', 'CA');
    
    await changeLanguage(newLocale);
  }

  /// Get current language display name
  String get currentLanguageDisplayName {
    switch (state.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      default:
        return 'Français';
    }
  }

  /// Check if current language is French
  bool get isFrench => state.languageCode == 'fr';

  /// Check if current language is English
  bool get isEnglish => state.languageCode == 'en';
}

/// Language provider
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

/// Current language display name provider
final currentLanguageDisplayNameProvider = Provider<String>((ref) {
  final languageNotifier = ref.watch(languageProvider.notifier);
  return languageNotifier.currentLanguageDisplayName;
});

/// Is French provider
final isFrenchProvider = Provider<bool>((ref) {
  final locale = ref.watch(languageProvider);
  return locale.languageCode == 'fr';
});

/// Is English provider
final isEnglishProvider = Provider<bool>((ref) {
  final locale = ref.watch(languageProvider);
  return locale.languageCode == 'en';
});