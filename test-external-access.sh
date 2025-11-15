#!/bin/bash
# Cognee External Access Diagnostic Script
# Run this script to diagnose external connectivity issues with your Coolify deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="cognee.v1su4.com"
NEO4J_DOMAIN="neo4j-cognee.v1su4.com"
QDRANT_DOMAIN="qdrant-cognee.v1su4.com"
INTERNAL_PORT=8000

echo -e "${BLUE}🔍 Cognee External Access Diagnostic Tool${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

# Function to check command result
check_result() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC}"
    else
        echo -e "${RED}❌ FAIL${NC}"
    fi
}

# Function to test HTTP endpoint
test_endpoint() {
    local url=$1
    local expected_status=${2:-200}
    echo -n "Testing $url... "

    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)

    if [ "$response" = "$expected_status" ]; then
        echo -e "${GREEN}✅ $response${NC}"
        return 0
    else
        echo -e "${RED}❌ $response${NC}"
        return 1
    fi
}

echo -e "${YELLOW}1. Checking Docker Container Status${NC}"
echo "======================================"

# Check if we're on the server with Docker access
if command -v docker &> /dev/null; then
    echo "📦 Container Status:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(cognee|neo4j|qdrant|postgres)" || echo "No Cognee containers found"
    echo ""

    echo "🏥 Container Health:"
    for container in $(docker ps --format "{{.Names}}" | grep -E "(cognee|neo4j|qdrant|postgres)"); do
        health=$(docker inspect "$container" --format='{{.State.Health.Status}}' 2>/dev/null || echo "no health check")
        if [ "$health" = "healthy" ]; then
            echo -e "  $container: ${GREEN}healthy${NC}"
        elif [ "$health" = "unhealthy" ]; then
            echo -e "  $container: ${RED}unhealthy${NC}"
        else
            echo -e "  $container: ${YELLOW}$health${NC}"
        fi
    done
    echo ""

    echo "🔗 Testing Internal Connectivity:"
    echo -n "  Internal health check (localhost:$INTERNAL_PORT/health)... "
    if curl -s http://localhost:$INTERNAL_PORT/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Working${NC}"
        INTERNAL_STATUS="working"
    else
        echo -e "${RED}❌ Failed${NC}"
        INTERNAL_STATUS="failed"
    fi
    echo ""
else
    echo -e "${YELLOW}⚠️ Docker not available. Run this script on the Coolify server for container diagnostics.${NC}"
    echo ""
    INTERNAL_STATUS="unknown"
fi

echo -e "${YELLOW}2. DNS Resolution Test${NC}"
echo "====================="

echo -n "  Resolving $DOMAIN... "
if nslookup "$DOMAIN" > /dev/null 2>&1; then
    SERVER_IP=$(nslookup "$DOMAIN" | grep -A1 "Name:" | tail -n1 | awk '{print $2}')
    echo -e "${GREEN}✅ Resolves to: $SERVER_IP${NC}"
    DNS_STATUS="working"
else
    echo -e "${RED}❌ DNS resolution failed${NC}"
    DNS_STATUS="failed"
fi

echo -n "  Resolving $NEO4J_DOMAIN... "
if nslookup "$NEO4J_DOMAIN" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Working${NC}"
else
    echo -e "${RED}❌ Failed${NC}"
fi

echo -n "  Resolving $QDRANT_DOMAIN... "
if nslookup "$QDRANT_DOMAIN" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Working${NC}"
else
    echo -e "${RED}❌ Failed${NC}"
fi
echo ""

echo -e "${YELLOW}3. External HTTPS Connectivity${NC}"
echo "================================"

# Test main API endpoints
test_endpoint "https://$DOMAIN/health" 200
test_endpoint "https://$DOMAIN/status" 200
test_endpoint "https://$DOMAIN/" 200

# Test if docs are accessible
echo -n "Testing API documentation... "
if curl -s "https://$DOMAIN/docs" | grep -q "Cognee\|FastAPI\|swagger" 2>/dev/null; then
    echo -e "${GREEN}✅ Accessible${NC}"
else
    echo -e "${RED}❌ Not accessible${NC}"
fi
echo ""

echo -e "${YELLOW}4. SSL Certificate Check${NC}"
echo "========================="

echo -n "  Checking SSL certificate for $DOMAIN... "
if echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | openssl x509 -noout -dates > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Valid certificate${NC}"
    cert_expiry=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | openssl x509 -noout -dates | grep "notAfter" | cut -d= -f2)
    echo "     Expires: $cert_expiry"
    SSL_STATUS="working"
else
    echo -e "${RED}❌ Certificate error${NC}"
    SSL_STATUS="failed"
fi
echo ""

echo -e "${YELLOW}5. Port Accessibility Test${NC}"
echo "=========================="

if [ "$DNS_STATUS" = "working" ] && [ -n "$SERVER_IP" ]; then
    echo -n "  Testing port 443 (HTTPS) accessibility... "
    if nc -z -w5 "$SERVER_IP" 443 2>/dev/null; then
        echo -e "${GREEN}✅ Port 443 open${NC}"
    else
        echo -e "${RED}❌ Port 443 blocked/closed${NC}"
    fi

    echo -n "  Testing port 80 (HTTP) accessibility... "
    if nc -z -w5 "$SERVER_IP" 80 2>/dev/null; then
        echo -e "${GREEN}✅ Port 80 open${NC}"
    else
        echo -e "${RED}❌ Port 80 blocked/closed${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Skipping port test (DNS resolution failed)${NC}"
fi
echo ""

echo -e "${YELLOW}6. API Functionality Test${NC}"
echo "========================="

if curl -s "https://$DOMAIN/health" > /dev/null 2>&1; then
    echo -n "  Testing API status endpoint... "
    if response=$(curl -s "https://$DOMAIN/status" 2>/dev/null) && echo "$response" | jq . > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Working${NC}"
        echo "     Response: $(echo "$response" | jq -c .)"
    else
        echo -e "${RED}❌ Invalid response${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Skipping API tests (health endpoint not accessible)${NC}"
fi
echo ""

echo -e "${BLUE}📊 DIAGNOSTIC SUMMARY${NC}"
echo -e "${BLUE}===================${NC}"

# Provide diagnosis and recommendations
if [ "$INTERNAL_STATUS" = "working" ] && curl -s "https://$DOMAIN/health" > /dev/null 2>&1; then
    echo -e "${GREEN}🎉 SUCCESS: Your Cognee API is externally accessible!${NC}"
    echo ""
    echo -e "${GREEN}✅ Main API: https://$DOMAIN${NC}"
    echo -e "${GREEN}✅ Documentation: https://$DOMAIN/docs${NC}"
    echo -e "${GREEN}✅ Health Check: https://$DOMAIN/health${NC}"

elif [ "$INTERNAL_STATUS" = "failed" ]; then
    echo -e "${RED}❌ INTERNAL ISSUE: Containers are not working properly${NC}"
    echo ""
    echo -e "${YELLOW}Recommended fixes:${NC}"
    echo "1. Check container logs: docker logs <container-name>"
    echo "2. Verify environment variables in Coolify"
    echo "3. Ensure all required API keys are set"
    echo "4. Check container dependencies (PostgreSQL, Neo4j, Qdrant)"

elif [ "$DNS_STATUS" = "failed" ]; then
    echo -e "${RED}❌ DNS ISSUE: Domain not resolving${NC}"
    echo ""
    echo -e "${YELLOW}Recommended fixes:${NC}"
    echo "1. Add DNS A record: $DOMAIN → YOUR_SERVER_IP"
    echo "2. Wait for DNS propagation (5-60 minutes)"
    echo "3. Check domain registrar settings"
    echo "4. Verify domain ownership"

elif [ "$SSL_STATUS" = "failed" ]; then
    echo -e "${RED}❌ SSL ISSUE: Certificate problems${NC}"
    echo ""
    echo -e "${YELLOW}Recommended fixes:${NC}"
    echo "1. In Coolify: Go to Domains → Regenerate Certificate"
    echo "2. Ensure port 80 is accessible (needed for Let's Encrypt)"
    echo "3. Check Coolify logs for certificate errors"
    echo "4. Verify domain is properly configured in Coolify UI"

else
    echo -e "${RED}❌ ROUTING ISSUE: External access blocked${NC}"
    echo ""
    echo -e "${YELLOW}Recommended fixes:${NC}"
    echo "1. Configure domain in Coolify dashboard (not just docker-compose)"
    echo "2. Check firewall: sudo ufw allow 80,443/tcp"
    echo "3. Verify Traefik is running: docker ps | grep traefik"
    echo "4. Check Coolify domain configuration"
fi

echo ""
echo -e "${BLUE}🔗 Useful Links:${NC}"
echo "  • Coolify Dashboard: https://coolify.yourdomain.com"
echo "  • API Documentation: https://$DOMAIN/docs (when working)"
echo "  • Neo4j Browser: https://$NEO4J_DOMAIN (when configured)"
echo "  • Troubleshooting Guide: ./TROUBLESHOOT_EXTERNAL_ACCESS.md"

echo ""
echo -e "${BLUE}📞 Next Steps:${NC}"
echo "  1. Fix the issues identified above"
echo "  2. Re-run this script to verify fixes"
echo "  3. If problems persist, check Coolify logs and container logs"

echo ""
echo -e "${BLUE}💡 Quick Manual Tests:${NC}"
echo "  • Test health: curl https://$DOMAIN/health"
echo "  • Check DNS: nslookup $DOMAIN"
echo "  • View docs: Open https://$DOMAIN/docs in browser"

exit 0
