# Thryfted - Flutter Fashion Marketplace

**Project Type**: Flutter mobile application (iOS/Android)  
**Mission**: Sustainable fashion resale marketplace similar to Vinted  
**Language**: Dart with Flutter framework  
**State Management**: Riverpod with code generation  
**Authentication**: Dual system (Clerk + Firebase fallback)  

## Development Commands

**IMPORTANT : THE COMMANDS BELOW SHOULD NOT BE EXECUTED, ONLY PROPOSED AT THE END RESULT**
```bash
# Essential Flutter commands
flutter pub get                       # Install dependencies
flutter clean && flutter pub get      # Clean install dependencies
flutter devices                       # List available devices

# Code generation (required after model changes)
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter packages pub run build_runner watch  # Watch for changes

# Internationalization (rebuild after .arb file changes)
flutter gen-l10n                      # Generate localization files

# Testing and quality
flutter test                          # Run unit tests
flutter test --coverage              # Run tests with coverage
flutter analyze                      # Static analysis
flutter doctor                       # Check development environment

# iOS Build (Currently working method)
# 1. Open Xcode: open ios/Runner.xcworkspace
# 2. Select iPhone 16 Pro simulator
# 3. Build and Run with Xcode (⌘+R)

# Note: flutter run currently has codesigning issues on iOS
# Use Xcode direct build until resolved

# Environment setup
cp .env.example .env                  # Copy environment template
# Edit .env with your API keys and configuration
```

## Project Structure

```
lib/
├── core/                    # Core infrastructure & business logic
│   ├── auth/               # Clerk & Firebase authentication
│   ├── config/             # App configuration & environment
│   ├── models/             # Data models with json_serializable
│   ├── navigation/         # GoRouter configuration
│   ├── providers/          # Riverpod providers (global state)
│   ├── services/           # Business services & API clients
│   └── utils/              # Utilities & helpers
├── features/               # Feature-based organization
│   ├── auth/               # Authentication screens
│   ├── home/               # Home screen & marketplace
│   ├── messages/           # Real-time messaging
│   ├── profile/            # User profile management
│   ├── search/             # Product search & filtering
│   └── sell/               # Item listing creation
├── l10n/                   # Internationalization
│   ├── app_en.arb         # English translations
│   └── app_fr.arb         # French translations (default)
├── shared/                 # Shared UI components
│   ├── theme/             # AppTheme & Material Design 3
│   └── widgets/           # Reusable widgets
└── main.dart              # App entry point
```

## Code Style & Patterns

### State Management (Riverpod)
```dart
// Use @riverpod annotation for code generation
@riverpod
class AuthNotifier extends _$AuthNotifier {
  // Implementation
}

// Consumer widgets for reactive UI
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    // Build UI
  }
}
```

### Navigation (GoRouter)
```dart
// Declarative routing with nested shell routes
GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [/* tab routes */],
    ),
  ],
)
```

### Internationalization
```dart
// Access translations in widgets
final l10n = AppLocalizations.of(context)!;
Text(l10n.welcomeToThryfted)

// French Canadian is default locale
// Run flutter gen-l10n after editing .arb files
```

## Architecture Patterns

- **Clean Architecture**: Core/Features/Shared separation
- **Feature-First**: Organize by business capability, not technical layer
- **Provider Pattern**: Riverpod for dependency injection & state management
- **Repository Pattern**: Abstract API clients through repositories
- **Code Generation**: Heavy use of build_runner for type safety

## Authentication System

**Dual Authentication Strategy**:
- **Primary**: Clerk Authentication (clerk_flutter: ^0.0.10-beta)
- **Fallback**: Firebase Auth for migration support
- **Configuration**: Environment-driven feature flags in .env

```dart
// Clerk integration with ClerkAuthBuilder
ClerkAuthBuilder(
  signedInBuilder: (context, authState) => _buildMainApp(),
  signedOutBuilder: (context, authState) => _buildAuthFlow(),
)
```

## Development Environment

### Required Tools
- Flutter 3.24.3+ with Dart 3.5.3+
- Xcode 16+ for iOS development
- Android Studio for Android development
- VS Code with Flutter/Dart extensions

### Environment Configuration
```bash
# Copy and configure environment
cp .env.example .env
# Update with actual API keys and configuration
```

### Key Dependencies
```yaml
# State Management
flutter_riverpod: ^2.6.1
riverpod_annotation: ^2.4.1

# Navigation
go_router: ^14.6.2

# Authentication
clerk_flutter: ^0.0.10-beta
firebase_auth: ^5.3.3

# HTTP & APIs
dio: ^5.7.0

# Real-time Database & Chat
web_socket_channel: ^2.4.0

# Environment Configuration
flutter_dotenv: ^5.1.0

# Internationalization
intl: ^0.20.2
flutter_localizations: sdk
```

## Real-time Chat System (Convex)

### Backend Structure
```
convex/
├── schema.ts           # Database schema for users, conversations, messages
├── messages.ts         # Message functions (send, get, mark read, typing)
├── conversations.ts    # Conversation management 
├── users.ts           # User management and sync with Clerk
└── _generated/        # Auto-generated TypeScript definitions
```

### Chat Features Implemented
- **Real-time messaging**: WebSocket-based real-time updates
- **Conversation management**: Between buyers and sellers for items
- **Message types**: Text, offers, system messages, images
- **Typing indicators**: Real-time typing status
- **Read receipts**: Unread counts and marking messages as read
- **Search**: Filter conversations by item, user, or message content

### Convex Setup Required
1. Create a Convex project at https://convex.dev
2. Update `convex.json` with your project URL
3. Update `lib/core/services/convex_service.dart` with your WebSocket URL
4. Deploy Convex functions: `npx convex deploy`
5. Set up Clerk authentication integration in Convex dashboard

### Chat Navigation
- Messages tab (3rd tab) shows all conversations
- Tap conversation to open chat detail screen
- Buyers can make offers on items
- Real-time updates for new messages and typing

## Important Notes

### Code Generation Requirements
- Run `build_runner build` after changes to:
  - Models with `@JsonSerializable()`
  - Providers with `@riverpod`

**Note**: Retrofit dependencies have been removed to simplify the project. Use Dio directly for HTTP requests.

### Internationalization
- **Default Language**: French Canadian (fr_CA)
- **Secondary**: English Canadian (en_CA)
- Update both `app_en.arb` and `app_fr.arb` for new strings
- Run `flutter gen-l10n` after ARB file changes

### Testing
- Unit tests: `flutter test`
- Integration tests: `flutter test integration_test/`
- No extensive test suite currently - opportunity for improvement

### Platform Considerations
- **Primary Target**: iOS and Android mobile apps
- **iOS**: Requires macOS for building
- **Android**: Cross-platform development

## Workflow Best Practices

1. **After pulling changes**: `flutter pub get && build_runner build`
2. **After model changes**: Run code generation
3. **After .arb changes**: Run `flutter gen-l10n`
4. **Before committing**: Run `flutter analyze` and `flutter test`
5. **Environment setup**: Use scripts in `/scripts/` directory

## Debugging & Common Issues

### RenderFlex Overflow
- Common in complex layouts
- Use `Flexible` or `Expanded` widgets
- Check MainScaffold navigation for reference

### Build Runner Issues
```bash
# Clean and regenerate
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Clerk Authentication
- Ensure .env file has correct keys
- Check ClerkConfig initialization in logs
- Use `./scripts/setup-clerk.sh` for initial setup

### Localization Issues
- Verify ARB files don't have underscore-prefixed keys
- Ensure l10n.yaml configuration is correct
- Check generated files in `.dart_tool/flutter_gen/`

## Project Cleanup (December 2024)

The codebase has been cleaned up to remove unnecessary dependencies and files:

### Removed Dependencies
- `hive_flutter` - Not used anywhere in codebase
- `retrofit` & `retrofit_generator` - Simplified to use Dio directly
- `flutter_svg` - No SVG assets found
- `cached_network_image` - Not imported anywhere
- `uuid` - Not used in current implementation  
- `geolocator` - Location features not implemented
- `local_auth` - Biometric auth not implemented

### Cleaned Up Files
- Removed duplicate iOS directories (`Flutter 2`, `Runner 2`, etc.)
- Removed unused source files (`main_simple.dart`, `profile_screen_old.dart`)
- Removed empty test directories and examples
- Fixed broken test file to use correct app class (`ThryfedApp`)
- Updated `.gitignore` with comprehensive Flutter/iOS/Convex patterns

### Build Process
- Use Xcode direct build for iOS (codesigning workaround)
- Flutter run currently has iOS codesigning issues
- Environment variables properly loaded via flutter_dotenv

**Impact**: ~500MB disk space saved, ~2MB app size reduction, 10-15% faster builds

---

*This CLAUDE.md reflects the actual Flutter codebase structure. Update as the project evolves.*

Be brutally honest, don't be a yes man. 
If I am wrong, point it out bluntly. 
I need honest feedback on my code.

always update you `CLAUDE.md` memory from changes you make inside the app

never use any emojies

only use .env for env

check docs/HOW-TO-RUN.md everything you have to run