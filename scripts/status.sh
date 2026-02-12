#!/bin/bash
# scripts/status.sh - Check SimpleBank environment status

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

# Detect OS
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    DOCKER_SUDO=""
    DOCKER_IT="-i"
else
    DOCKER_SUDO="sudo"
    DOCKER_IT="-it"
fi

echo -e "${BLUE}📊 SimpleBank Environment Status:${NC}"
echo "=================================="

echo -e "${BLUE}🐳 Docker Containers:${NC}"
$DOCKER_SUDO docker ps -a --filter name=postgres12 --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo -e "${BLUE}🗄️  Databases:${NC}"
$DOCKER_SUDO docker exec $DOCKER_IT postgres12 psql -U root -l 2>/dev/null || echo "⚠️  PostgreSQL container not running"

echo ""
echo -e "${GREEN}✅ Status check complete!${NC}"