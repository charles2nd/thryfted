#!/bin/bash
set -e

echo "🔨 Building Thryfted for iOS Simulator..."

# Navigate to iOS directory
cd ios

# Build with Xcode (bypassing codesigning issues)
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build

echo "📱 Installing on simulator..."

# Find and install the app
APP_PATH=$(find /Users/charles/Library/Developer/Xcode/DerivedData -name "Runner.app" -type d | head -1)
xcrun simctl install 900D2921-1B10-4D29-8207-C45A082D10AE "$APP_PATH"

echo "🎉 Launching Thryfted..."

# Launch the app
xcrun simctl launch 900D2921-1B10-4D29-8207-C45A082D10AE com.thryfted.app

echo "✅ Thryfted is running on iPhone 16 Pro simulator!"
echo "💬 Navigate to Messages tab (3rd tab) to test chat functionality"