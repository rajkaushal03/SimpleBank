#!/bin/bash
# scripts/reset.sh - Reset SimpleBank environment

set -e

# Colors for output
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 Resetting SimpleBank environment...${NC}"

# Run cleanup
./scripts/cleanup.sh

# Wait before reinstall
echo -e "${BLUE}⏳ Waiting 3 seconds before reinstall...${NC}"
sleep 3

# Run install
./scripts/install.sh

echo -e "${BLUE}✅ Reset complete!${NC}"