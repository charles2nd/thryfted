#!/bin/bash

# Thryfted Development Environment Setup Script
# This script sets up the complete development environment

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "\n🔹 $1\n"
}

# Check if running from project root
if [ ! -f "package.json" ] || [ ! -d "backend" ] || [ ! -d "mobile" ]; then
    print_error "Please run this script from the Thryfted project root directory"
    exit 1
fi

print_info "Starting Thryfted Development Setup..."

# Check for required tools
print_info "Checking required tools..."

# Check Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js 18+ first."
    echo "Visit: https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_error "Node.js version 18+ is required. Current version: $(node -v)"
    exit 1
fi
print_success "Node.js $(node -v) found"

# Check npm
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed."
    exit 1
fi
print_success "npm $(npm -v) found"

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    echo "Visit: https://www.docker.com/products/docker-desktop/"
    echo "See our Docker setup guide: docs/DOCKER_SETUP_GUIDE.md"
    exit 1
fi
print_success "Docker $(docker --version | cut -d' ' -f3 | cut -d',' -f1) found"

# Check Docker Compose
if ! docker compose version &> /dev/null; then
    print_error "Docker Compose is not available."
    exit 1
fi
print_success "Docker Compose found"

# Check if Docker is running
if ! docker info &> /dev/null; then
    print_error "Docker is not running. Please start Docker Desktop."
    exit 1
fi
print_success "Docker is running"

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    print_info "Creating .env file from template..."
    cp .env.example .env
    print_success ".env file created"
    print_warning "Please review and update .env file with your configuration"
else
    print_success ".env file already exists"
fi

# Install root dependencies
print_info "Installing root dependencies..."
npm install
print_success "Root dependencies installed"

# Install backend dependencies
print_info "Installing backend dependencies..."
cd backend
npm install
cd ..
print_success "Backend dependencies installed"

# Install mobile dependencies
print_info "Installing mobile dependencies..."
cd mobile
npm install

# iOS specific setup (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_info "Setting up iOS dependencies..."
    if command -v pod &> /dev/null; then
        cd ios
        pod install
        cd ..
        print_success "iOS dependencies installed"
    else
        print_warning "CocoaPods not found. Run 'sudo gem install cocoapods' to install."
    fi
fi

cd ..
print_success "Mobile dependencies installed"

# Start Docker services
print_info "Starting Docker services..."
docker compose up -d

# Wait for services to be ready
print_info "Waiting for services to start..."
sleep 10

# Check service health
SERVICES_HEALTHY=true

# Check PostgreSQL
if docker compose exec -T postgres pg_isready -U thryfted &> /dev/null; then
    print_success "PostgreSQL is ready"
else
    print_error "PostgreSQL is not ready"
    SERVICES_HEALTHY=false
fi

# Check Redis
if docker compose exec -T redis redis-cli ping &> /dev/null; then
    print_success "Redis is ready"
else
    print_error "Redis is not ready"
    SERVICES_HEALTHY=false
fi

# Check Elasticsearch
if curl -s http://localhost:9200/_cluster/health &> /dev/null; then
    print_success "Elasticsearch is ready"
else
    print_error "Elasticsearch is not ready"
    SERVICES_HEALTHY=false
fi

# Check MongoDB
if docker compose exec -T mongodb mongosh --eval "db.adminCommand('ping')" &> /dev/null; then
    print_success "MongoDB is ready"
else
    print_error "MongoDB is not ready"
    SERVICES_HEALTHY=false
fi

# Check MinIO
if curl -s http://localhost:9000/minio/health/live &> /dev/null; then
    print_success "MinIO is ready"
else
    print_error "MinIO is not ready"
    SERVICES_HEALTHY=false
fi

if [ "$SERVICES_HEALTHY" = false ]; then
    print_warning "Some services are not ready. Check logs with: docker compose logs"
fi

# Run database migrations
print_info "Setting up databases..."
cd backend/services/user-service

# Generate Prisma client
print_info "Generating Prisma client..."
npx prisma generate
print_success "Prisma client generated"

# Run migrations
print_info "Running database migrations..."
if npx prisma migrate dev --name init; then
    print_success "Database migrations completed"
else
    print_warning "Database migrations failed. You may need to run them manually."
fi

cd ../../..

# Create MinIO buckets
print_info "Creating MinIO storage buckets..."
if docker compose exec -T minio mc alias set local http://localhost:9000 thryfted thryfted_password &> /dev/null; then
    docker compose exec -T minio mc mb local/thryfted-images --ignore-existing
    docker compose exec -T minio mc mb local/thryfted-avatars --ignore-existing
    docker compose exec -T minio mc mb local/thryfted-documents --ignore-existing
    docker compose exec -T minio mc anonymous set download local/thryfted-images
    print_success "MinIO buckets created"
else
    print_warning "Failed to create MinIO buckets. You may need to create them manually."
fi

# Summary
print_info "Setup Complete! 🎉"

echo ""
echo "Service URLs:"
echo "  🔗 API Gateway:       http://localhost:3000"
echo "  🔗 pgAdmin:           http://localhost:8080 (admin@thryfted.com / admin)"
echo "  🔗 Redis Commander:   http://localhost:8081"
echo "  🔗 MinIO Console:     http://localhost:9001 (thryfted / thryfted_password)"
echo "  🔗 Elasticsearch:     http://localhost:9200"
echo ""
echo "Next steps:"
echo "  1. Review and update the .env file with your configuration"
echo "  2. Start the backend services:  cd backend && npm run dev"
echo "  3. Start the mobile app:        cd mobile && npm run ios (or android)"
echo ""
echo "To stop Docker services:         docker compose stop"
echo "To view logs:                    docker compose logs -f"
echo ""

print_success "Happy coding! 🚀"