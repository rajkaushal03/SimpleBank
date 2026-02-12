#!/bin/bash
# scripts/softclean.sh - Clean database data only

set -e

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

echo -e "${BLUE}🧹 Cleaning database data (keeping structure)...${NC}"

$DOCKER_SUDO docker exec $DOCKER_IT postgres12 psql -U root -d simplebank \
    -c "TRUNCATE TABLE transfers, entries, accounts RESTART IDENTITY CASCADE;"

echo -e "${GREEN}✅ Database data cleaned!${NC}"