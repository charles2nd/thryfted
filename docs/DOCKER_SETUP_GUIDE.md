# Docker Setup Guide for Thryfted Development

This guide will walk you through setting up Docker from scratch and running the Thryfted development environment.

## Table of Contents
1. [Installing Docker](#installing-docker)
2. [Verifying Installation](#verifying-installation)
3. [Understanding Docker Compose](#understanding-docker-compose)
4. [Running Thryfted Services](#running-thryfted-services)
5. [Managing Containers](#managing-containers)
6. [Troubleshooting](#troubleshooting)
7. [Useful Commands](#useful-commands)

## Installing Docker

### macOS Installation

#### Option 1: Docker Desktop (Recommended)
1. Visit [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/)
2. Download Docker Desktop for Mac (Apple Silicon or Intel chip)
3. Open the downloaded `.dmg` file
4. Drag Docker to your Applications folder
5. Launch Docker from Applications
6. Follow the setup wizard

#### Option 2: Using Homebrew
```bash
# Install Docker Desktop via Homebrew
brew install --cask docker

# Launch Docker
open /Applications/Docker.app
```

### Windows Installation

#### Prerequisites
- Windows 10 64-bit: Pro, Enterprise, or Education (Build 19041 or higher)
- OR Windows 11
- Enable WSL 2 feature

#### Steps
1. Visit [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
2. Download Docker Desktop for Windows
3. Run the installer
4. Follow the installation wizard
5. Restart your computer when prompted
6. Launch Docker Desktop

### Linux Installation (Ubuntu/Debian)

```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add your user to docker group (to run without sudo)
sudo usermod -aG docker $USER
newgrp docker
```

## Verifying Installation

After installation, verify Docker is working correctly:

```bash
# Check Docker version
docker --version
# Expected output: Docker version 24.x.x, build xxxxxxx

# Check Docker Compose version
docker compose version
# Expected output: Docker Compose version v2.x.x

# Test Docker installation
docker run hello-world
# This should download a test image and display a success message
```

## Understanding Docker Compose

Our `docker-compose.yml` file defines all the services needed for Thryfted development:

- **PostgreSQL**: Main relational database
- **Redis**: Caching and session storage
- **Elasticsearch**: Search functionality
- **MongoDB**: Messages and logs storage
- **MinIO**: S3-compatible file storage
- **pgAdmin**: PostgreSQL management UI
- **Redis Commander**: Redis management UI

## Running Thryfted Services

### 1. Navigate to Project Directory
```bash
cd /Users/charles/Documents/projets_sulside/thryfted
```

### 2. Create Environment File
Create a `.env` file in the project root:

```bash
# Create .env file
cat > .env << 'EOF'
# Database Configuration
POSTGRES_USER=thryfted
POSTGRES_PASSWORD=thryfted_password
POSTGRES_DB=thryfted_dev
DATABASE_URL=postgresql://thryfted:thryfted_password@localhost:5432/thryfted_dev

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379

# MongoDB Configuration
MONGO_USER=thryfted
MONGO_PASSWORD=thryfted_password
MONGO_DB=thryfted_messages
MONGODB_URL=mongodb://thryfted:thryfted_password@localhost:27017/thryfted_messages

# Elasticsearch Configuration
ELASTICSEARCH_URL=http://localhost:9200

# MinIO (S3-compatible storage)
MINIO_ROOT_USER=thryfted
MINIO_ROOT_PASSWORD=thryfted_password
MINIO_ENDPOINT=http://localhost:9000

# Service URLs
USER_SERVICE_URL=http://localhost:3001
CATALOG_SERVICE_URL=http://localhost:3002
SEARCH_SERVICE_URL=http://localhost:3003
MESSAGING_SERVICE_URL=http://localhost:3004
PAYMENT_SERVICE_URL=http://localhost:3005
SHIPPING_SERVICE_URL=http://localhost:3006
NOTIFICATION_SERVICE_URL=http://localhost:3007

# JWT Configuration
JWT_SECRET=thryfted-development-secret-change-in-production
JWT_EXPIRY=7d

# Node Environment
NODE_ENV=development
EOF
```

### 3. Start All Services
```bash
# Start all services in detached mode
docker compose up -d

# View logs for all services
docker compose logs -f

# Or view logs for specific service
docker compose logs -f postgres
```

### 4. Verify Services are Running
```bash
# Check container status
docker compose ps

# All services should show "running" status
```

### 5. Access Service UIs

Once all services are running, you can access:

- **pgAdmin** (PostgreSQL UI): http://localhost:8080
  - Email: `admin@thryfted.com`
  - Password: `admin`
  
- **Redis Commander**: http://localhost:8081
  
- **MinIO Console**: http://localhost:9001
  - Username: `thryfted`
  - Password: `thryfted_password`

- **Elasticsearch**: http://localhost:9200

## Managing Containers

### Starting Services
```bash
# Start all services
docker compose up -d

# Start specific service
docker compose up -d postgres redis

# Start with logs visible
docker compose up
```

### Stopping Services
```bash
# Stop all services (keeps data)
docker compose stop

# Stop and remove containers (keeps data)
docker compose down

# Stop and remove everything including volumes (DELETES ALL DATA)
docker compose down -v
```

### Viewing Logs
```bash
# View all logs
docker compose logs

# Follow logs (real-time)
docker compose logs -f

# View specific service logs
docker compose logs -f postgres

# View last 100 lines
docker compose logs --tail=100
```

### Accessing Container Shell
```bash
# Access PostgreSQL shell
docker compose exec postgres psql -U thryfted -d thryfted_dev

# Access Redis CLI
docker compose exec redis redis-cli

# Access MongoDB shell
docker compose exec mongodb mongosh -u thryfted -p thryfted_password

# Access any container's bash shell
docker compose exec [service-name] /bin/bash
```

## Database Initialization

### PostgreSQL Setup
```bash
# Access PostgreSQL
docker compose exec postgres psql -U thryfted -d thryfted_dev

# Inside PostgreSQL shell, you can:
# List databases
\l

# List tables
\dt

# Exit
\q
```

### Create MinIO Buckets
```bash
# Access MinIO container
docker compose exec minio /bin/bash

# Create buckets for different file types
mc alias set local http://localhost:9000 thryfted thryfted_password
mc mb local/thryfted-images
mc mb local/thryfted-avatars
mc mb local/thryfted-documents

# Set public read policy for images
mc anonymous set download local/thryfted-images
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Port Already in Use
```bash
# Error: bind: address already in use

# Find what's using the port (example for port 5432)
sudo lsof -i :5432

# Kill the process
sudo kill -9 <PID>

# Or change the port in docker-compose.yml
```

#### 2. Permission Denied
```bash
# On Linux, if you get permission denied
sudo usermod -aG docker $USER
newgrp docker
# Log out and back in
```

#### 3. Container Keeps Restarting
```bash
# Check logs for the specific container
docker compose logs [service-name]

# Common causes:
# - Wrong credentials in .env file
# - Insufficient memory
# - Port conflicts
```

#### 4. Docker Desktop Not Starting (macOS)
- Check if virtualization is enabled in BIOS
- Try resetting Docker Desktop to factory defaults
- Reinstall Docker Desktop

#### 5. Slow Performance
```bash
# Increase Docker Desktop memory allocation:
# Docker Desktop → Preferences → Resources → Memory
# Recommended: At least 4GB for Thryfted

# Check resource usage
docker stats
```

## Useful Commands

### Docker Commands Cheatsheet
```bash
# List all containers
docker ps -a

# Remove all stopped containers
docker container prune

# List all images
docker images

# Remove unused images
docker image prune -a

# Check disk usage
docker system df

# Clean up everything (BE CAREFUL)
docker system prune -a --volumes

# Monitor resource usage
docker stats

# Copy files from container
docker cp container_name:/path/to/file ./local/path

# Execute command in running container
docker exec -it container_name command
```

### Docker Compose Commands
```bash
# Rebuild containers
docker compose build

# Rebuild without cache
docker compose build --no-cache

# Scale service
docker compose up -d --scale redis=3

# View service configuration
docker compose config

# Pull latest images
docker compose pull

# Restart specific service
docker compose restart [service-name]
```

## Development Workflow

### Daily Development
1. **Start your day**:
   ```bash
   cd /path/to/thryfted
   docker compose up -d
   ```

2. **Check services**:
   ```bash
   docker compose ps
   ```

3. **Develop your code**
   - Node.js services will auto-restart with nodemon
   - Database changes persist in Docker volumes

4. **End of day**:
   ```bash
   docker compose stop
   ```

### Database Migrations
```bash
# Run Prisma migrations for User Service
cd backend/services/user-service
npm run db:migrate

# Generate Prisma client
npm run db:generate
```

### Resetting Everything
```bash
# Stop all containers and remove volumes (DELETES ALL DATA)
docker compose down -v

# Start fresh
docker compose up -d

# Run migrations
npm run db:migrate
```

## Next Steps

Once Docker is running:

1. **Install Node.js dependencies**:
   ```bash
   npm install
   cd backend && npm install
   cd ../mobile && npm install
   ```

2. **Run database migrations**:
   ```bash
   cd backend/services/user-service
   npm run db:migrate
   ```

3. **Start development servers**:
   ```bash
   # Terminal 1: Start backend services
   cd backend
   npm run dev
   
   # Terminal 2: Start mobile app
   cd mobile
   npm run ios  # or npm run android
   ```

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Desktop Troubleshooting](https://docs.docker.com/desktop/troubleshooting/)

---

**Happy Development! 🚀**

If you encounter any issues not covered in this guide, please check the Thryfted repository issues or create a new one.