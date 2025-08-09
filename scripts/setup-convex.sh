#!/bin/bash
set -e

echo "🚀 Setting up Convex for Thryfted..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "convex.json" ]; then
    echo "❌ convex.json not found. Make sure you're in the project root."
    exit 1
fi

echo "📦 Installing Convex CLI globally..."
npm install -g convex

echo "🔧 Initializing Convex project..."
npx convex dev --once

echo "📤 Deploying Convex functions..."
npx convex deploy

echo "✅ Convex setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Copy your Convex project URL to .env file"
echo "2. Configure Clerk authentication in Convex dashboard"
echo "3. Build and test your Flutter app"
echo ""
echo "📚 See CONVEX_SETUP.md for detailed instructions"