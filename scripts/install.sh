#!/bin/bash
# scripts/install.sh - Complete SimpleBank installation

set -e  # Exit on error

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

echo -e "${BLUE}🚀 Starting SimpleBank installation...${NC}"

# Step 1: Start PostgreSQL container
echo -e "${YELLOW}📦 Step 1: Starting PostgreSQL container...${NC}"
if $DOCKER_SUDO docker ps -a --format '{{.Names}}' | grep -q "^postgres12$"; then
    echo -e "${YELLOW}⚠️  PostgreSQL container already exists${NC}"
    if ! $DOCKER_SUDO docker ps --format '{{.Names}}' | grep -q "^postgres12$"; then
        echo -e "${YELLOW}🔄 Starting existing container...${NC}"
        $DOCKER_SUDO docker start postgres12
    else
        echo -e "${GREEN}✅ Container already running${NC}"
    fi
else
    $DOCKER_SUDO docker run --name postgres12 -p 5432:5432 \
        -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret \
        -d postgres:12-alpine
    echo -e "${GREEN}✅ PostgreSQL container started${NC}"
fi

# Step 2: Wait for PostgreSQL to be ready
echo -e "${YELLOW}⏳ Waiting for PostgreSQL to be ready...${NC}"
sleep 5

# Step 3: Create production database
echo -e "${YELLOW}🗄️  Step 2: Creating production database...${NC}"
if $DOCKER_SUDO docker exec $DOCKER_IT postgres12 psql -U root -lqt | cut -d \| -f 1 | grep -qw simplebank; then
    echo -e "${YELLOW}⚠️  Production database already exists${NC}"
else
    $DOCKER_SUDO docker exec $DOCKER_IT postgres12 createdb --username=root --owner=root simplebank
    echo -e "${GREEN}✅ Production database created${NC}"
fi

# Step 4: Run production migrations
echo -e "${YELLOW}⬆️  Step 3: Running production migrations...${NC}"
migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank?sslmode=disable" -verbose up
echo -e "${GREEN}✅ Production migrations completed${NC}"

# Step 5: Create test database
echo -e "${YELLOW}🧪 Step 4: Creating test database...${NC}"
if $DOCKER_SUDO docker exec $DOCKER_IT postgres12 psql -U root -lqt | cut -d \| -f 1 | grep -qw simplebank_test; then
    echo -e "${YELLOW}⚠️  Test database already exists${NC}"
else
    $DOCKER_SUDO docker exec $DOCKER_IT postgres12 createdb --username=root --owner=root simplebank_test
    echo -e "${GREEN}✅ Test database created${NC}"
fi

# Step 6: Run test migrations
echo -e "${YELLOW}⬆️  Step 5: Running test migrations...${NC}"
migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank_test?sslmode=disable" -verbose up
echo -e "${GREEN}✅ Test migrations completed${NC}"

# Step 7: List databases
echo -e "${BLUE}📋 Available databases:${NC}"
$DOCKER_SUDO docker exec $DOCKER_IT postgres12 psql -U root -l

echo -e "${GREEN}✅ Installation complete! SimpleBank is ready to use.${NC}"