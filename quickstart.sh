#!/bin/bash

# Cognee Quick Start Script
# This script helps you get Cognee up and running quickly

set -e

echo "🚀 Cognee Quick Start Setup"
echo "================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    echo "✅ .env file created"
    echo ""
    echo "⚠️  IMPORTANT: Please edit .env file and set:"
    echo "   - LLM_API_KEY (your OpenAI API key)"
    echo "   - EMBEDDING_API_KEY (your OpenAI API key)"
    echo "   - POSTGRES_PASSWORD (a secure password)"
    echo "   - NEO4J_PASSWORD (a secure password)"
    echo ""
    read -p "Press Enter after you've updated the .env file..."
else
    echo "✅ .env file already exists"
fi

echo ""
echo "🐳 Starting Docker services..."
echo ""

# Pull images first
echo "📥 Pulling Docker images..."
docker-compose pull

echo ""
echo "🚀 Starting services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be healthy..."
echo "   This may take 1-2 minutes, especially on first run..."
echo ""

# Wait for services to be healthy
MAX_ATTEMPTS=60
ATTEMPT=0

check_health() {
    local service=$1
    local url=$2
    
    while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            return 0
        fi
        ATTEMPT=$((ATTEMPT + 1))
        echo -n "."
        sleep 2
    done
    return 1
}

# Check Cognee API
echo -n "Checking Cognee API"
if check_health "cognee" "http://localhost:8000/health"; then
    echo " ✅"
else
    echo " ❌"
    echo "Cognee API failed to start. Check logs with: docker-compose logs cognee"
    exit 1
fi

echo ""
echo "✅ All services are running!"
echo ""
echo "🎉 Cognee is ready!"
echo "================================"
echo ""
echo "📊 Service URLs:"
echo "   - Cognee API: http://localhost:8000"
echo "   - API Docs: http://localhost:8000/docs"
echo "   - Neo4j Browser: http://localhost:7474"
echo "   - Qdrant Dashboard: http://localhost:6333/dashboard"
echo ""
echo "🧪 Test the API:"
echo '   curl http://localhost:8000/health'
echo ""
echo "📖 Next steps:"
echo "   1. Visit http://localhost:8000/docs for API documentation"
echo "   2. Check README.md for Goose integration"
echo "   3. Check DEPLOYMENT.md for Coolify deployment"
echo ""
echo "📝 Useful commands:"
echo "   - View logs: docker-compose logs -f"
echo "   - Stop services: docker-compose down"
echo "   - Restart: docker-compose restart"
echo ""

