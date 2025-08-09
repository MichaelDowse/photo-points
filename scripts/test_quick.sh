#!/bin/bash

# Quick test runner for development
# Runs tests without coverage for faster feedback

set -e

echo "🚀 Quick Test Run..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get dependencies
flutter pub get

# Run unit tests only
echo -e "${BLUE}🧪 Running unit tests...${NC}"
flutter test test/unit/

# Run widget tests
echo -e "${BLUE}🎨 Running widget tests...${NC}"
flutter test test/widget/

# Quick analysis
echo -e "${BLUE}🔍 Running quick analysis...${NC}"
flutter analyze --no-fatal-infos

echo -e "${GREEN}✅ Quick tests completed!${NC}"
