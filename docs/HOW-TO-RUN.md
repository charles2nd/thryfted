# How to Run Thryfted iOS App

This guide explains how to run the Thryfted Flutter app on iOS simulator after resolving codesigning issues.

## Prerequisites

- macOS with Xcode 16+ installed
- Flutter 3.24.3+ with Dart 3.5.3+
- iOS Simulator running
- CocoaPods installed

## Quick Start

### Method 1: Working Direct Build (✅ Tested & Working)

This method bypasses Flutter's codesigning issues completely:

```bash
# 1. Prepare dependencies
flutter clean && flutter pub get
cd ios && pod install && cd ..

# 2. Build with xcodebuild directly (no code signing)
cd ios && xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'id=900D2921-1B10-4D29-8207-C45A082D10AE' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  DEVELOPMENT_TEAM=""

# 3. Install and launch the app
xcrun simctl install booted /Users/charles/Library/Developer/Xcode/DerivedData/Runner-*/Build/Products/Debug-iphonesimulator/Runner.app
xcrun simctl launch booted com.thryfted.app.thryftedFlutter
```

### Method 2: Use the Build Script (✅ Recommended)

```bash
# Use the automated build script
./scripts/build-simulator.sh
```

### Method 3: Flutter Run (❌ Currently Broken)

Due to codesigning issues with Flutter's build pipeline:

```bash
# This currently fails with codesigning errors
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

The automated build script at `scripts/build-simulator.sh` handles the entire process:

```bash
#!/bin/bash
set -e

echo "Building Thryfted for iOS Simulator..."

# Clean up previous builds
echo "Cleaning previous builds..."
flutter clean
flutter pub get

# Generate necessary files
echo "Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build for simulator using xcodebuild directly
echo "Building with xcodebuild..."
cd ios

xcodebuild clean -workspace Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphonesimulator

xcodebuild build -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  DEVELOPMENT_TEAM="" \
  PROVISIONING_PROFILE="" \
  SKIP_INSTALL=NO \
  ONLY_ACTIVE_ARCH=NO

echo "Build completed successfully!"
echo "You can now install the app to simulator using:"
echo "xcrun simctl install booted /path/to/Runner.app"
```

To run it:
```bash
chmod +x scripts/build-simulator.sh
./scripts/build-simulator.sh
```

## Notes

- **Primary Target**: iOS and Android mobile apps
- **Default Language**: French Canadian (fr_CA)  
- **Secondary**: English Canadian (en_CA)
- **Bundle ID**: com.thryfted.app.thryftedFlutter
- **Simulator ID**: 900D2921-1B10-4D29-8207-C45A082D10AE (iPhone 16 Pro)

## Viewing App Logs

### Method 1: Flutter Logs (Best for Flutter apps)
```bash
flutter logs --device-id=900D2921-1B10-4D29-8207-C45A082D10AE
```

### Method 2: Xcode Console
```bash
# Open Xcode, then Window → Devices and Simulators → Select iPhone 16 Pro → View Device Logs
open -a Xcode
```

### Method 3: macOS Console App
```bash
# Console is now open - look for iPhone 16 Pro on left sidebar
# Filter by process name "Runner" or "com.thryfted.app"
open -a Console
```

### Method 4: Terminal Log Stream  
```bash
xcrun simctl spawn 900D2921-1B10-4D29-8207-C45A082D10AE log stream --predicate 'process CONTAINS "Runner"'
```

### Method 5: Check if App is Printing Logs
Your Flutter app needs `debugPrint()` or `print()` statements to see logs. Check your `lib/main.dart`:

```dart
void main() async {
  print("🚀 THRYFTED APP STARTING!");
  // ... rest of your code
}
```

**Recommended:** Use **Method 1** (`flutter logs`) as it's designed for Flutter apps and shows `debugPrint()` output.

## Working Configuration

The project has been configured with the following key changes to bypass code signing issues:

### iOS Configuration Files

1. **ios/Podfile**: Updated to iOS 13.0+ for Firebase compatibility
```ruby
platform :ios, '13.0'
```

2. **ios/Flutter/Debug.xcconfig** & **ios/Flutter/Release.xcconfig**: Code signing disabled
```
CODE_SIGNING_REQUIRED = NO
CODE_SIGNING_ALLOWED = NO
CODE_SIGN_IDENTITY = ""
CODE_SIGN_STYLE = Manual
DEVELOPMENT_TEAM = ""
```

3. **Build Process**: Uses direct `xcodebuild` command with specific flags to bypass Flutter's code signing pipeline

### Key Success Factors

- **iOS 13.0+ Target**: Required for Firebase dependencies
- **Direct xcodebuild**: Bypasses Flutter's build pipeline that enforces code signing
- **Specific Device ID**: Uses exact simulator ID for consistent targeting
- **Code Signing Disabled**: All signing requirements removed for simulator builds

## Support

If you encounter issues:

1. Check `flutter doctor` for environment problems
2. Verify iOS Simulator is running with: `xcrun simctl list devices`
3. Clean build if dependencies are outdated: `flutter clean && cd ios && pod install`
4. Use Method 1 (Direct xcodebuild) to bypass Flutter codesigning issues
5. Ensure simulator device ID matches: `900D2921-1B10-4D29-8207-C45A082D10AE`

## Recent Updates (August 2025)

- ✅ Fixed iOS 13.0 compatibility for Firebase
- ✅ Resolved code signing issues for simulator builds
- ✅ Created automated build script: `scripts/build-simulator.sh`
- ✅ Verified working on iPhone 16 Pro simulator (iOS 18.6)

---

*Generated for Thryfted - Sustainable Fashion Resale Marketplace*