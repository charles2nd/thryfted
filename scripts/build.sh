#!/bin/bash

# Flutter build script for Thryfted app

echo "🚀 Building Thryfted Flutter App"
echo "================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

echo "✅ Flutter version:"
flutter --version | head -1

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Generate code (if needed)
echo "🔧 Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs || echo "⚠️  Code generation skipped (no generators configured)"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Build for Android (APK)
echo "🤖 Building Android APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo "✅ Android APK build successful!"
    echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
else
    echo "❌ Android APK build failed"
fi

# Build for iOS (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Building iOS..."
    flutter build ios --release --no-codesign
    
    if [ $? -eq 0 ]; then
        echo "✅ iOS build successful!"
        echo "📱 iOS build location: build/ios/iphoneos/Runner.app"
    else
        echo "❌ iOS build failed"
    fi
else
    echo "⚠️  Skipping iOS build (not on macOS)"
fi

echo "🎉 Build process completed!"
echo ""
echo "To run the app in development:"
echo "  flutter run"
echo ""
echo "To run on specific device:"
echo "  flutter devices"
echo "  flutter run -d <device-id>"