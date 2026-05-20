#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🧹 Cleaning up...${NC}"
rm -rf node_modules yarn.lock package-lock.json .next

echo -e "${YELLOW}📦 Installing dependencies with yarn...${NC}"
yarn install

echo -e "${YELLOW}🔨 Building project...${NC}"
yarn build

echo -e "${GREEN}✅ Setup complete!${NC}"
echo -e "${YELLOW}To start development, run:${NC}"
echo -e "${GREEN}yarn dev${NC}"
