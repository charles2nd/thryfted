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
echo "App should be built in build/ios/Debug-iphonesimulator/"

# Go back to root directory
cd ..

echo "You can now install the app to simulator using:"
echo "xcrun simctl install booted build/ios/Debug-iphonesimulator/Runner.app"