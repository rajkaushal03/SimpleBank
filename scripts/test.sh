#!/bin/bash
set -e

echo "🚀 Starting complete test cycle..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Cleanup function
cleanup() {
    echo -e "${BLUE}🧹 Cleaning up...${NC}"
    make droptestdb 2>/dev/null || true
    echo -e "${GREEN}✅ Cleanup complete!${NC}"
}

# Register cleanup on exit (runs even if tests fail)
trap cleanup EXIT

# Create database
echo -e "${BLUE}📦 Creating test database...${NC}"
make createtestdb

# Run migrations
echo -e "${BLUE}⬆️  Running migrations...${NC}"
make migrateuptestdb

# Run tests
echo -e "${BLUE}🧪 Running tests...${NC}"
go test -v -cover ./db/sqlc

echo -e "${GREEN}✅ All tests passed!${NC}"