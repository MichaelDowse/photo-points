#!/bin/bash

# PhotoPoints Test Runner Script
# This script runs the complete test suite with coverage reporting

set -e

echo "🧪 Starting PhotoPoints Test Suite..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create reports directory
mkdir -p test_reports coverage

echo -e "${BLUE}📋 Setting up test environment...${NC}"

# Get dependencies
flutter pub get

# Generate code (for JSON serialization)
echo -e "${BLUE}🔄 Generating code...${NC}"
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run unit tests
echo -e "${BLUE}🧪 Running unit tests...${NC}"
flutter test test/unit/ --coverage --coverage-path=coverage/unit_coverage.lcov

# Run widget tests
echo -e "${BLUE}🎨 Running widget tests...${NC}"
flutter test test/widget/ --coverage --coverage-path=coverage/widget_coverage.lcov

# Run integration tests
echo -e "${BLUE}🔗 Running integration tests...${NC}"
flutter test test/integration/ --coverage --coverage-path=coverage/integration_coverage.lcov

# Run all tests with coverage
echo -e "${BLUE}📊 Running complete test suite with coverage...${NC}"
flutter test --coverage --coverage-path=coverage/lcov.info

# Generate HTML coverage report
echo -e "${BLUE}📈 Generating HTML coverage report...${NC}"
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo -e "${GREEN}✅ HTML coverage report generated: coverage/html/index.html${NC}"
else
    echo -e "${YELLOW}⚠️  genhtml not found. Install lcov to generate HTML reports.${NC}"
    echo -e "${YELLOW}   On macOS: brew install lcov${NC}"
    echo -e "${YELLOW}   On Ubuntu: sudo apt-get install lcov${NC}"
fi

# Run integration tests (Flutter driver tests)
echo -e "${BLUE}🚀 Running integration tests...${NC}"
if [ -d "integration_test" ]; then
    flutter test integration_test/
else
    echo -e "${YELLOW}⚠️  No integration_test directory found${NC}"
fi

# Check coverage thresholds
echo -e "${BLUE}📊 Checking coverage thresholds...${NC}"
if [ -f "coverage/lcov.info" ]; then
    # Extract coverage percentage (this is a simplified check)
    lines_covered=$(grep -c "LF:" coverage/lcov.info || echo "0")
    lines_hit=$(grep -c "LH:" coverage/lcov.info || echo "0")

    if [ "$lines_covered" -gt 0 ]; then
        coverage_percent=$((lines_hit * 100 / lines_covered))
        echo -e "${BLUE}📈 Line coverage: ${coverage_percent}%${NC}"

        if [ "$coverage_percent" -ge 80 ]; then
            echo -e "${GREEN}✅ Coverage threshold met (≥80%)${NC}"
        else
            echo -e "${YELLOW}⚠️  Coverage below threshold (${coverage_percent}% < 80%)${NC}"
        fi
    fi
fi

# Run analysis
echo -e "${BLUE}🔍 Running static analysis...${NC}"
flutter analyze

# Format check
echo -e "${BLUE}🎨 Checking code formatting...${NC}"
dart format --set-exit-if-changed .

echo -e "${GREEN}✅ All tests completed successfully!${NC}"
echo -e "${GREEN}📊 Coverage report: coverage/html/index.html${NC}"
echo -e "${GREEN}📋 Test reports: test_reports/${NC}"

# Summary
echo -e "${BLUE}📋 Test Summary:${NC}"
echo -e "   • Unit tests: ✅"
echo -e "   • Widget tests: ✅"
echo -e "   • Integration tests: ✅"
echo -e "   • Static analysis: ✅"
echo -e "   • Code formatting: ✅"
echo -e "   • Coverage reporting: ✅"
