#!/bin/bash

# Thryfted Flutter iOS Development Script
# Automates app deployment, installation, and logging for iOS devices
# Usage: ./run-dev-ios.sh [device-name]

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# App configuration
APP_NAME="Thryfted"
BUNDLE_ID="com.thryfted.flutter"
BUILD_DIR="build/ios/iphoneos"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE} 📱 Thryfted iOS Development Script${NC}"
    echo -e "${PURPLE}========================================${NC}"
}

# Function to check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check iOS development setup
    if ! flutter doctor | grep -q "iOS toolchain"; then
        print_error "iOS toolchain not properly configured"
        print_status "Run 'flutter doctor' for more information"
        exit 1
    fi
    
    # Check Xcode
    if ! command -v xcrun &> /dev/null; then
        print_error "Xcode command line tools not installed"
        exit 1
    fi
    
    # Check ios-deploy for device deployment
    if ! command -v ios-deploy &> /dev/null; then
        print_warning "ios-deploy not found. Installing via npm..."
        if command -v npm &> /dev/null; then
            npm install -g ios-deploy
        else
            print_error "npm not found. Please install Node.js and npm, then run: npm install -g ios-deploy"
            exit 1
        fi
    fi
    
    print_success "All prerequisites are met"
}

# Function to list available devices
list_devices() {
    print_status "Available iOS devices:"
    flutter devices --machine | jq -r '.[] | select(.platform == "ios" and .type == "device") | "  - \(.name) (\(.id))"' 2>/dev/null || {
        # Fallback if jq is not available
        flutter devices | grep "ios" | grep -v "simulator"
    }
}

# Function to select device
select_device() {
    if [ -n "$1" ]; then
        DEVICE_NAME="$1"
        print_status "Using specified device: $DEVICE_NAME"
    else
        # Get list of iOS devices
        DEVICES=$(flutter devices --machine 2>/dev/null | jq -r '.[] | select(.platform == "ios" and .type == "device") | .id' 2>/dev/null || echo "")
        
        if [ -z "$DEVICES" ]; then
            print_error "No iOS devices found. Please connect your iOS device and trust this computer."
            print_status "Available devices:"
            list_devices
            exit 1
        fi
        
        # If only one device, use it
        DEVICE_COUNT=$(echo "$DEVICES" | wc -l | tr -d ' ')
        if [ "$DEVICE_COUNT" -eq 1 ]; then
            DEVICE_ID="$DEVICES"
            print_status "Using device: $DEVICE_ID"
        else
            # Multiple devices - show selection
            print_status "Multiple devices found:"
            list_devices
            echo
            read -p "Enter device name or ID: " DEVICE_NAME
        fi
    fi
    
    # Validate device exists
    if ! flutter devices | grep -q "$DEVICE_NAME\|$DEVICE_ID"; then
        print_error "Device '$DEVICE_NAME' not found"
        list_devices
        exit 1
    fi
    
    # Use device ID if we have it, otherwise use device name
    TARGET_DEVICE="${DEVICE_ID:-$DEVICE_NAME}"
}

# Function to check if app is installed on device
check_app_installation() {
    print_status "Checking if app is installed on device..."
    
    # Get device UDID
    if [ -n "$DEVICE_ID" ]; then
        UDID="$DEVICE_ID"
    else
        UDID=$(flutter devices --machine 2>/dev/null | jq -r ".[] | select(.name == \"$DEVICE_NAME\") | .id" 2>/dev/null || echo "")
    fi
    
    if [ -z "$UDID" ]; then
        print_warning "Could not determine device UDID. Will perform fresh installation."
        return 1
    fi
    
    # Check if app is installed using ios-deploy
    if ios-deploy --id "$UDID" --exists --bundle_id "$BUNDLE_ID" &>/dev/null; then
        print_success "App is already installed on device"
        return 0
    else
        print_status "App is not installed on device"
        return 1
    fi
}

# Function to validate environment
validate_environment() {
    print_status "Validating environment configuration..."
    
    # Check for .env file
    if [ ! -f ".env" ]; then
        print_warning ".env file not found"
        if [ -f ".env.example" ]; then
            print_status "Creating .env from .env.example"
            cp .env.example .env
            print_warning "Please update .env file with your configuration"
        else
            print_error "No .env.example found. Please create .env file with required configuration"
            exit 1
        fi
    fi
    
    # Check critical environment variables
    if grep -q "CONVEX_URL=.*your-convex-url" .env 2>/dev/null; then
        print_warning "CONVEX_URL not configured in .env"
    fi
    
    if grep -q "CLERK_PUBLISHABLE_KEY=.*your-clerk-key" .env 2>/dev/null; then
        print_warning "CLERK_PUBLISHABLE_KEY not configured in .env"
    fi
    
    print_success "Environment validation complete"
}

# Function to clean and prepare build
prepare_build() {
    print_status "Preparing build environment..."
    
    # Clean previous builds
    print_status "Cleaning previous builds..."
    flutter clean
    
    # Get dependencies
    print_status "Getting Flutter dependencies..."
    flutter pub get
    
    # Run code generation if needed
    if ls lib/**/*.g.dart 2>/dev/null | head -1 >/dev/null; then
        print_status "Running code generation..."
        flutter packages pub run build_runner build --delete-conflicting-outputs
    fi
    
    # Generate localization files
    if [ -f "l10n.yaml" ]; then
        print_status "Generating localization files..."
        flutter gen-l10n
    fi
    
    print_success "Build environment prepared"
}

# Function to build and install/update app
deploy_app() {
    local is_installed=$1
    
    if [ "$is_installed" = "true" ]; then
        print_status "Updating existing app installation..."
        ACTION="update"
    else
        print_status "Installing app on device..."
        ACTION="install"
    fi
    
    # Build and deploy to device
    print_status "Building and deploying to device: $TARGET_DEVICE"
    
    # Use flutter run with specific device
    if [ -n "$TARGET_DEVICE" ]; then
        FLUTTER_CMD="flutter run -d \"$TARGET_DEVICE\" --debug --hot --verbose"
    else
        FLUTTER_CMD="flutter run --debug --hot --verbose"
    fi
    
    print_status "Executing: $FLUTTER_CMD"
    
    # Run Flutter in background and capture PID
    eval "$FLUTTER_CMD" &
    FLUTTER_PID=$!
    
    # Wait a moment for app to start
    sleep 5
    
    # Check if Flutter process is still running
    if kill -0 "$FLUTTER_PID" 2>/dev/null; then
        print_success "App deployed successfully (PID: $FLUTTER_PID)"
        print_status "Hot reload is enabled. Press 'r' to reload, 'R' to restart, 'q' to quit."
        
        # Monitor the process
        wait "$FLUTTER_PID"
    else
        print_error "App deployment failed"
        exit 1
    fi
}

# Function to stream logs (alternative method)
stream_logs() {
    print_status "Setting up log streaming..."
    
    # Get device UDID for logging
    if [ -n "$DEVICE_ID" ]; then
        UDID="$DEVICE_ID"
    else
        UDID=$(flutter devices --machine 2>/dev/null | jq -r ".[] | select(.name == \"$DEVICE_NAME\") | .id" 2>/dev/null || echo "")
    fi
    
    if [ -n "$UDID" ]; then
        print_status "Streaming device logs for $BUNDLE_ID..."
        print_status "You can now navigate the app. Logs will appear below:"
        print_status "Press Ctrl+C to stop log streaming"
        echo
        
        # Stream logs using xcrun
        xcrun devicectl list devices 2>/dev/null | grep -q "$UDID" && {
            xcrun devicectl device process launch --device "$UDID" --start-stopped "$BUNDLE_ID" 2>/dev/null || true
        }
        
        # Alternative log streaming methods
        ios-deploy --id "$UDID" --bundle_id "$BUNDLE_ID" --debug --noninteractive 2>/dev/null || {
            print_warning "ios-deploy logging failed, trying alternative method..."
            xcrun simctl spawn booted log stream --predicate "subsystem contains '$BUNDLE_ID'" 2>/dev/null || {
                print_warning "Direct log streaming not available, use flutter logs for debugging"
            }
        }
    else
        print_warning "Could not determine device UDID for log streaming"
        print_status "Use 'flutter logs' command in another terminal for debugging"
    fi
}

# Function to cleanup on exit
cleanup() {
    print_status "Cleaning up..."
    if [ -n "$FLUTTER_PID" ] && kill -0 "$FLUTTER_PID" 2>/dev/null; then
        print_status "Stopping Flutter process..."
        kill "$FLUTTER_PID" 2>/dev/null || true
    fi
    print_success "Cleanup complete"
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

# Main execution
main() {
    print_header
    
    # Check if running from correct directory
    if [ ! -f "pubspec.yaml" ]; then
        print_error "Please run this script from the Flutter project root directory"
        exit 1
    fi
    
    # Run all steps
    check_prerequisites
    validate_environment
    select_device "$1"
    
    # Check installation status
    if check_app_installation; then
        IS_INSTALLED="true"
    else
        IS_INSTALLED="false"
    fi
    
    prepare_build
    deploy_app "$IS_INSTALLED"
}

# Execute main function with all arguments
main "$@"