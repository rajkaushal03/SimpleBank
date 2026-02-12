#!/bin/bash
# scripts/cleanup.sh - Complete SimpleBank cleanup

set +e  # Don't exit on error (cleanup should continue)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect OS
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    DOCKER_SUDO=""
    DOCKER_IT="-i"
else
    DOCKER_SUDO="sudo"
    DOCKER_IT="-it"
fi

echo -e "${BLUE}🧹 Starting cleanup process...${NC}"

# Step 1: Rollback test migrations
echo -e "${YELLOW}⬇️  Step 1: Rolling back test database migrations...${NC}"
migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank_test?sslmode=disable" -verbose down -all 2>/dev/null || echo -e "${YELLOW}⚠️  Test migrations already rolled back or database doesn't exist${NC}"

# Step 2: Drop test database
echo -e "${YELLOW}🗑️  Step 2: Dropping test database...${NC}"
$DOCKER_SUDO docker exec $DOCKER_IT postgres12 dropdb simplebank_test 2>/dev/null || echo -e "${YELLOW}⚠️  Test database already dropped or doesn't exist${NC}"

# Step 3: Rollback production migrations
echo -e "${YELLOW}⬇️  Step 3: Rolling back production database migrations...${NC}"
migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank?sslmode=disable" -verbose down -all 2>/dev/null || echo -e "${YELLOW}⚠️  Production migrations already rolled back or database doesn't exist${NC}"

# Step 4: Drop production database
echo -e "${YELLOW}🗑️  Step 4: Dropping production database...${NC}"
$DOCKER_SUDO docker exec $DOCKER_IT postgres12 dropdb simplebank 2>/dev/null || echo -e "${YELLOW}⚠️  Production database already dropped or doesn't exist${NC}"

# Step 5: Stop and remove container
echo -e "${YELLOW}🛑 Step 5: Stopping and removing PostgreSQL container...${NC}"
$DOCKER_SUDO docker stop postgres12 2>/dev/null || echo -e "${YELLOW}⚠️  Container already stopped${NC}"
$DOCKER_SUDO docker rm postgres12 2>/dev/null || echo -e "${YELLOW}⚠️  Container already removed${NC}"

echo -e "${GREEN}✅ Cleanup complete! All databases and containers removed.${NC}"