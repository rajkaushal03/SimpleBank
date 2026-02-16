#!/bin/bash
# scripts/install.sh - Complete SimpleBank installation
# Works in both local development and GitHub Actions

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting SimpleBank installation...${NC}"

# Detect environment
if [ -n "$GITHUB_ACTIONS" ]; then
    echo -e "${BLUE}🔧 Running in GitHub Actions environment${NC}"
    IN_CI=true
    DOCKER_SUDO=""
    DOCKER_IT=""
else
    echo -e "${BLUE}🔧 Running in local development environment${NC}"
    IN_CI=false
    # Detect OS for local development
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        DOCKER_SUDO=""
        DOCKER_IT="-i"
    else
        DOCKER_SUDO="sudo"
        DOCKER_IT="-it"
    fi
fi

# Step 1: Start PostgreSQL (local only)
if [ "$IN_CI" = false ]; then
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
            -e POSTGRES_USER=root \
            -e POSTGRES_PASSWORD=secret \
            -e POSTGRES_DB=simplebank \
            -d postgres:12-alpine
        echo -e "${GREEN}✅ PostgreSQL container started${NC}"
    fi
    
    echo -e "${YELLOW}⏳ Waiting for PostgreSQL to be ready...${NC}"
    sleep 5
else
    echo -e "${GREEN}✅ Using GitHub Actions PostgreSQL service${NC}"
fi

# Step 2: Create production database
echo -e "${YELLOW}🗄️  Step 2: Setting up production database...${NC}"
if [ "$IN_CI" = true ]; then
    # In CI, simplebank database already exists (POSTGRES_DB env var)
    echo -e "${GREEN}✅ Production database already exists (created by service)${NC}"
else
    # In local, check if database exists
    if $DOCKER_SUDO docker exec $DOCKER_IT postgres12 psql -U root -lqt | cut -d \| -f 1 | grep -qw simplebank; then
        echo -e "${YELLOW}⚠️  Production database already exists${NC}"
    else
        $DOCKER_SUDO docker exec $DOCKER_IT postgres12 createdb --username=root --owner=root simplebank
        echo -e "${GREEN}✅ Production database created${NC}"
    fi
fi

# Step 3: Run production migrations
echo -e "${YELLOW}⬆️  Step 3: Running production migrations...${NC}"
migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank?sslmode=disable" -verbose up
echo -e "${GREEN}✅ Production migrations completed${NC}"

# Step 4: Create test database
echo -e "${YELLOW}🧪 Step 4: Creating test database...${NC}"
if [ "$IN_CI" = true ]; then
    # In CI, use psql via network
    if PGPASSWORD=secret psql -h localhost -U root -lqt | cut -d \| -f 1 | grep -qw simplebank_test; then
        echo -e "${YELLOW}⚠️  Test database already exists${NC}"
    else
        PGPASSWORD=secret createdb -h localhost -U root simplebank_test
        echo -e "${GREEN}✅ Test database created${NC}"
    fi
else
    # In local, use docker exec
    if $DOCKER_SUDO docker exec $DOCKER_IT postgres12 psql -U root -lqt | cut -d \| -f 1 | grep -qw simplebank_test; then
        echo -e "${YELLOW}⚠️  Test database already exists${NC}"
    else
        $DOCKER_SUDO docker exec $DOCKER_IT postgres12 createdb --username=root --owner=root simplebank_test
        echo -e "${GREEN}✅ Test database created${NC}"
    fi
fi

# Step 5: Run test migrations
echo -e "${YELLOW}⬆️  Step 5: Running test migrations...${NC}"
migrate -path db/migration -database "postgresql://root:secret@localhost:5432/simplebank_test?sslmode=disable" -verbose up
echo -e "${GREEN}✅ Test migrations completed${NC}"

# Step 6: List databases
echo -e "${BLUE}📋 Available databases:${NC}"
if [ "$IN_CI" = true ]; then
    PGPASSWORD=secret psql -h localhost -U root -l
else
    $DOCKER_SUDO docker exec $DOCKER_IT postgres12 psql -U root -l
fi

echo -e "${GREEN}✅ Installation complete! SimpleBank is ready to use.${NC}"