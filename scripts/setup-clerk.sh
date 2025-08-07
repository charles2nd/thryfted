#!/bin/bash

# Clerk Authentication Setup Script for Thryfted Flutter App
# This script helps set up Clerk authentication integration

set -e

echo "🔧 Setting up Clerk Authentication for Thryfted..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if required tools are installed
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed. Please install Flutter first."
        exit 1
    fi
    
    if ! command -v dart &> /dev/null; then
        print_error "Dart is not installed. Please install Dart first."
        exit 1
    fi
    
    print_success "All dependencies are installed"
}

# Install Flutter packages
install_packages() {
    print_status "Installing Flutter packages..."
    
    flutter pub get
    
    if [ $? -eq 0 ]; then
        print_success "Flutter packages installed successfully"
    else
        print_error "Failed to install Flutter packages"
        exit 1
    fi
}

# Generate code with build_runner
generate_code() {
    print_status "Generating code with build_runner..."
    
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    if [ $? -eq 0 ]; then
        print_success "Code generation completed"
    else
        print_warning "Code generation had some issues, but continuing..."
    fi
}

# Setup environment configuration
setup_environment() {
    print_status "Setting up environment configuration..."
    
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            print_success "Created .env file from .env.example"
            print_warning "Please update .env file with your actual Clerk keys"
        else
            print_error ".env.example file not found"
            exit 1
        fi
    else
        print_warning ".env file already exists. Skipping creation."
    fi
}

# Verify Clerk configuration
verify_clerk_config() {
    print_status "Verifying Clerk configuration..."
    
    if [ -f ".env" ]; then
        if grep -q "pk_test_your-clerk-publishable-key-here" .env; then
            print_warning "Please update your Clerk publishable key in .env file"
        else
            print_success "Clerk publishable key appears to be configured"
        fi
        
        if grep -q "sk_test_your-clerk-secret-key-here" .env; then
            print_warning "Please update your Clerk secret key in .env file"
        else
            print_success "Clerk secret key appears to be configured"
        fi
    else
        print_error ".env file not found"
        exit 1
    fi
}

# Create gitignore entries
setup_gitignore() {
    print_status "Setting up .gitignore..."
    
    if [ ! -f ".gitignore" ]; then
        touch .gitignore
    fi
    
    # Add environment files to gitignore if not already present
    if ! grep -q "\.env" .gitignore; then
        echo "" >> .gitignore
        echo "# Environment files" >> .gitignore
        echo ".env" >> .gitignore
        echo ".env.local" >> .gitignore
        echo ".env.production" >> .gitignore
        print_success "Added environment files to .gitignore"
    fi
    
    # Add other common Flutter ignores
    if ! grep -q "# Clerk" .gitignore; then
        echo "" >> .gitignore
        echo "# Clerk temporary files" >> .gitignore
        echo "clerk_cache/" >> .gitignore
        echo "*.clerk" >> .gitignore
    fi
}

# Setup Android configuration
setup_android() {
    print_status "Setting up Android configuration..."
    
    if [ -d "android/app/src/main" ]; then
        # Check if internet permission is added
        if ! grep -q "android.permission.INTERNET" android/app/src/main/AndroidManifest.xml; then
            print_warning "Please add INTERNET permission to android/app/src/main/AndroidManifest.xml"
        fi
        
        print_success "Android configuration ready"
    else
        print_warning "Android directory not found. Skipping Android setup."
    fi
}

# Setup iOS configuration
setup_ios() {
    print_status "Setting up iOS configuration..."
    
    if [ -d "ios/Runner" ]; then
        # Check if Info.plist has required configurations
        if [ -f "ios/Runner/Info.plist" ]; then
            print_success "iOS configuration ready"
        else
            print_warning "Info.plist not found. Please check iOS configuration."
        fi
    else
        print_warning "iOS directory not found. Skipping iOS setup."
    fi
}

# Run tests
run_tests() {
    print_status "Running tests..."
    
    if flutter test; then
        print_success "All tests passed"
    else
        print_warning "Some tests failed. Please check and fix them."
    fi
}

# Create development run script
create_run_script() {
    print_status "Creating development run script..."
    
    cat > run-dev.sh << 'EOF'
#!/bin/bash

# Development run script for Thryfted with Clerk

echo "🚀 Starting Thryfted development server with Clerk..."

# Load environment variables
if [ -f ".env" ]; then
    export $(cat .env | xargs)
fi

# Run Flutter app
flutter run --dart-define=CLERK_PUBLISHABLE_KEY="$CLERK_PUBLISHABLE_KEY" \
           --dart-define=CLERK_SECRET_KEY="$CLERK_SECRET_KEY" \
           --dart-define=API_BASE_URL="$API_BASE_URL" \
           --dart-define=ENABLE_CLERK_AUTH="$ENABLE_CLERK_AUTH"

EOF

    chmod +x run-dev.sh
    print_success "Created run-dev.sh script"
}

# Main setup function
main() {
    echo "🎯 Thryfted Clerk Authentication Setup"
    echo "======================================"
    
    check_dependencies
    install_packages
    setup_environment
    setup_gitignore
    setup_android
    setup_ios
    generate_code
    verify_clerk_config
    create_run_script
    
    echo ""
    echo "======================================"
    echo "🎉 Clerk Authentication Setup Complete!"
    echo "======================================"
    echo ""
    print_success "Next steps:"
    echo "1. Update your .env file with actual Clerk keys"
    echo "2. Configure your backend to handle Clerk webhooks"
    echo "3. Test authentication flows"
    echo "4. Run the app with: ./run-dev.sh"
    echo ""
    print_warning "Important notes:"
    echo "• Make sure your Clerk dashboard is configured properly"
    echo "• Set up your redirect URLs in Clerk dashboard"
    echo "• Configure social providers if needed"
    echo "• Test both sign-in and sign-up flows"
    echo ""
}

# Run main function
main "$@"