#!/bin/bash

# Health check script for all services
# This can be used for monitoring and alerting

set -e

COGNEE_URL="${COGNEE_URL:-http://localhost:8000}"
NEO4J_URL="${NEO4J_URL:-http://localhost:7474}"
QDRANT_URL="${QDRANT_URL:-http://localhost:6333}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🏥 Cognee Health Check"
echo "======================"
echo ""

# Function to check HTTP endpoint
check_http() {
    local name=$1
    local url=$2
    
    if curl -s -f "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $name is healthy${NC}"
        return 0
    else
        echo -e "${RED}❌ $name is not responding${NC}"
        return 1
    fi
}

# Function to check Docker container
check_container() {
    local name=$1
    local container=$2
    
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        local status=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null)
        if [ "$status" = "running" ]; then
            echo -e "${GREEN}✅ $name container is running${NC}"
            return 0
        else
            echo -e "${RED}❌ $name container status: $status${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ $name container not found${NC}"
        return 1
    fi
}

ALL_HEALTHY=true

# Check Cognee API
echo "Checking Cognee API..."
if check_http "Cognee API" "$COGNEE_URL/health"; then
    # Get status details
    STATUS=$(curl -s "$COGNEE_URL/status")
    echo "   Status: $STATUS"
else
    ALL_HEALTHY=false
fi
echo ""

# Check Neo4j
echo "Checking Neo4j..."
if check_container "Neo4j" "cognee-neo4j"; then
    check_http "Neo4j HTTP" "$NEO4J_URL" || ALL_HEALTHY=false
else
    ALL_HEALTHY=false
fi
echo ""

# Check Qdrant
echo "Checking Qdrant..."
if check_container "Qdrant" "cognee-qdrant"; then
    check_http "Qdrant" "$QDRANT_URL/health" || ALL_HEALTHY=false
else
    ALL_HEALTHY=false
fi
echo ""

# Check PostgreSQL
echo "Checking PostgreSQL..."
if check_container "PostgreSQL" "cognee-postgres"; then
    # Try to connect to PostgreSQL
    if docker exec cognee-postgres pg_isready -U cognee > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PostgreSQL is accepting connections${NC}"
    else
        echo -e "${RED}❌ PostgreSQL is not accepting connections${NC}"
        ALL_HEALTHY=false
    fi
else
    ALL_HEALTHY=false
fi
echo ""

# Check disk space
echo "Checking disk space..."
DISK_USAGE=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    echo -e "${GREEN}✅ Disk usage: ${DISK_USAGE}%${NC}"
else
    echo -e "${YELLOW}⚠️  Disk usage: ${DISK_USAGE}% (consider cleanup)${NC}"
fi
echo ""

# Check memory usage
echo "Checking memory usage..."
if command -v free &> /dev/null; then
    MEMORY_USAGE=$(free | awk 'NR==2 {printf "%.0f", $3/$2*100}')
    if [ "$MEMORY_USAGE" -lt 90 ]; then
        echo -e "${GREEN}✅ Memory usage: ${MEMORY_USAGE}%${NC}"
    else
        echo -e "${YELLOW}⚠️  Memory usage: ${MEMORY_USAGE}% (high)${NC}"
    fi
fi
echo ""

# Summary
echo "======================"
if [ "$ALL_HEALTHY" = true ]; then
    echo -e "${GREEN}🎉 All services are healthy!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some services are unhealthy${NC}"
    echo ""
    echo "📝 Troubleshooting steps:"
    echo "   1. Check logs: docker-compose logs"
    echo "   2. Restart services: docker-compose restart"
    echo "   3. Check environment variables: docker-compose config"
    exit 1
fi

