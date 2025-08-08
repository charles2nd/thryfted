# How to Run Thryfted iOS App

This guide explains how to run the Thryfted Flutter app on iOS simulator after resolving codesigning issues.

## Prerequisites

- macOS with Xcode 16+ installed
- Flutter 3.24.3+ with Dart 3.5.3+
- iOS Simulator running
- CocoaPods installed

## Quick Start

### Method 1: Direct Xcode Build (Recommended)

This method bypasses Flutter's problematic codesigning by using Xcode directly:

```bash
# Navigate to iOS directory
cd ios

# Build with Xcode (no codesigning)
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build

# Find and install the app
APP_PATH=$(find /Users/charles/Library/Developer/Xcode/DerivedData -name "Runner.app" -type d | head -1)
xcrun simctl install 900D2921-1B10-4D29-8207-C45A082D10AE "$APP_PATH"

# Launch the app
xcrun simctl launch 900D2921-1B10-4D29-8207-C45A082D10AE com.thryfted.app
```

### Method 2: Flutter Run (May Have Issues)

If the codesigning fixes are working properly:

```bash
flutter run -d "iPhone 16 Pro"
# or
flutter run -d 900D2921-1B10-4D29-8207-C45A082D10AE
```

## Device Management

### List Available Devices
```bash
flutter devices
```

### Start iOS Simulator
```bash
open -a Simulator
# or boot specific simulator
xcrun simctl boot 900D2921-1B10-4D29-8207-C45A082D10AE
```

### List All Simulators
```bash
xcrun simctl list devices
```

## Troubleshooting

### Codesigning Issues

If you encounter the error:
```
Target debug_unpack_ios failed: Exception: Failed to codesign /path/to/Flutter.framework/Flutter with identity -
```

**Solution**: Use Method 1 (Direct Xcode Build) above.

### Clean Build

If builds are failing, clean everything:

```bash
# Clean Flutter
flutter clean

# Clean iOS dependencies
rm -rf ios/Pods ios/Podfile.lock

# Clean Xcode derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Reinstall dependencies
flutter pub get
cd ios && pod install
```

### Rebuild Dependencies

After making changes to Podfile or xcconfig files:

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
```

## Project Configuration

### Codesigning Settings

The project has been configured to disable codesigning for simulator builds:

- **Debug.xcconfig** & **Release.xcconfig**: Codesigning disabled
- **Podfile**: Post-install hook disables codesigning for all pods
- **Xcode Project**: Manual signing with empty identity

### Key Files Modified

1. `ios/Flutter/Debug.xcconfig`
2. `ios/Flutter/Release.xcconfig` 
3. `ios/Podfile`
4. `ios/Runner.xcodeproj/project.pbxproj`

## Development Commands

```bash
# Essential Flutter commands
flutter run                           # Start development server
flutter run -d iPhone                 # Run on specific device
flutter devices                       # List available devices
flutter clean && flutter pub get      # Clean install dependencies

# Code generation (required after model changes)
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter packages pub run build_runner watch  # Watch for changes

# Internationalization (rebuild after .arb file changes)
flutter gen-l10n                      # Generate localization files

# Testing and quality
flutter test                          # Run unit tests
flutter analyze                      # Static analysis
flutter doctor                       # Check development environment
```

## Quick Run Script

Save this as `run-ios.sh` in the project root:

```bash
#!/bin/bash
set -e

echo "🚀 Building Thryfted iOS App..."

cd ios

# Build with Xcode
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build

echo "📱 Installing on simulator..."

# Find and install
APP_PATH=$(find /Users/charles/Library/Developer/Xcode/DerivedData -name "Runner.app" -type d | head -1)
xcrun simctl install 900D2921-1B10-4D29-8207-C45A082D10AE "$APP_PATH"

echo "🎉 Launching Thryfted..."

# Launch
xcrun simctl launch 900D2921-1B10-4D29-8207-C45A082D10AE com.thryfted.app

echo "✅ Thryfted is running on iPhone 16 Pro simulator!"
```

Make it executable:
```bash
chmod +x run-ios.sh
./run-ios.sh
```

## Notes

- **Primary Target**: iOS and Android mobile apps
- **Default Language**: French Canadian (fr_CA)  
- **Secondary**: English Canadian (en_CA)
- **Bundle ID**: com.thryfted.app
- **Simulator ID**: 900D2921-1B10-4D29-8207-C45A082D10AE (iPhone 16 Pro)

## Support

If you encounter issues:

1. Check `flutter doctor` for environment problems
2. Verify iOS Simulator is running
3. Clean build if dependencies are outdated
4. Use Method 1 (Xcode direct build) to bypass Flutter codesigning issues

---

*Generated for Thryfted - Sustainable Fashion Resale Marketplace*