# Thryfted - Flutter Marketplace App

A modern sustainable fashion marketplace app built with Flutter, enabling users to buy and sell secondhand clothing items.

## 🚀 Quick Start

```bash
# Install dependencies
flutter pub get

# Run on iOS simulator
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Build for production
flutter build ios --release
flutter build apk --release
```

## 📱 Features

- **Authentication**: Email/password login, registration, password reset
- **Navigation**: Bottom tabs (Home, Search, Sell, Messages, Profile)
- **State Management**: Riverpod for reactive state
- **API Integration**: Dio HTTP client with automatic token refresh
- **Secure Storage**: Encrypted local storage for sensitive data
- **Modern UI**: Material Design 3 with custom theming

## 🏗️ Architecture

```
lib/
├── core/           # Core business logic
│   ├── constants/  # App constants
│   ├── models/     # Data models
│   ├── services/   # API & Auth services
│   └── navigation/ # App routing
├── features/       # Feature modules
│   ├── auth/       # Authentication
│   ├── home/       # Home feed
│   ├── search/     # Search & browse
│   ├── sell/       # Create listings
│   ├── messages/   # Chat
│   └── profile/    # User profile
└── shared/         # Shared components
    ├── theme/      # App theming
    └── widgets/    # Reusable widgets
```

## 🔧 Configuration

### API Server
Update the API URL in `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://your-api-server.com/api/v1';
```

### Firebase (Optional)
1. Run `flutterfire configure`
2. Uncomment Firebase initialization in `lib/main.dart`

### iOS Requirements
- iOS 13.0+
- Xcode 14+

### Android Requirements
- Android API 21+
- Android Studio

## 🛠️ Development

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/

# Build runner (for code generation)
flutter pub run build_runner build
```

## 📄 License

MIT License - See LICENSE file for details
EOF < /dev/null