#!/bin/bash

# This script fixes iOS codesigning issues for simulator builds

echo "Fixing iOS codesigning for simulator..."

# Remove any existing codesign settings from project.pbxproj
sed -i '' 's/CODE_SIGN_IDENTITY = ".*"/CODE_SIGN_IDENTITY = ""/g' Runner.xcodeproj/project.pbxproj
sed -i '' 's/CODE_SIGN_STYLE = Automatic;/CODE_SIGN_STYLE = Manual;/g' Runner.xcodeproj/project.pbxproj
sed -i '' 's/DEVELOPMENT_TEAM = ".*"/DEVELOPMENT_TEAM = ""/g' Runner.xcodeproj/project.pbxproj

# Fix Flutter pod configs
if [ -f "Pods/Target Support Files/Flutter/Flutter.debug.xcconfig" ]; then
    if ! grep -q "CODE_SIGNING_REQUIRED" "Pods/Target Support Files/Flutter/Flutter.debug.xcconfig"; then
        echo -e "\nCODE_SIGN_IDENTITY = \nCODE_SIGNING_REQUIRED = NO\nCODE_SIGNING_ALLOWED = NO" >> "Pods/Target Support Files/Flutter/Flutter.debug.xcconfig"
    fi
fi

if [ -f "Pods/Target Support Files/Flutter/Flutter.release.xcconfig" ]; then
    if ! grep -q "CODE_SIGNING_REQUIRED" "Pods/Target Support Files/Flutter/Flutter.release.xcconfig"; then
        echo -e "\nCODE_SIGN_IDENTITY = \nCODE_SIGNING_REQUIRED = NO\nCODE_SIGNING_ALLOWED = NO" >> "Pods/Target Support Files/Flutter/Flutter.release.xcconfig"
    fi
fi

echo "Codesigning fix applied!"