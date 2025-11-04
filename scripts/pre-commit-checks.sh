#!/bin/bash

# Pre-commit validation script
# Runs all checks that CI/CD will run (Jenkins + GitHub Actions)

set -e  # Exit on first error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}🔍 Running Pre-Commit Validation Checks${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Track failures
FAILED=0

# Function to run a check and track status
run_check() {
    local check_name=$1
    local check_cmd=$2
    
    echo -e "${YELLOW}▶ ${check_name}...${NC}"
    if eval "$check_cmd"; then
        echo -e "${GREEN}✅ ${check_name} passed${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}❌ ${check_name} failed${NC}"
        echo ""
        FAILED=1
        return 1
    fi
}

# 1. Go Format Check
run_check "Go Format Check" '
    UNFORMATTED=$(gofmt -l .)
    if [ -n "$UNFORMATTED" ]; then
        echo "The following files are not formatted:"
        echo "$UNFORMATTED"
        echo ""
        echo "Run: go fmt ./..."
        exit 1
    fi
'

# 2. Go Vet (Static Analysis)
run_check "Go Vet (Static Analysis)" "go vet ./..."

# 3. Go Mod Verify
run_check "Go Mod Verify" "go mod verify"

# 4. Go Mod Tidy Check
run_check "Go Mod Tidy Check" '
    cp go.mod go.mod.backup
    cp go.sum go.sum.backup
    go mod tidy
    if ! diff -q go.mod go.mod.backup >/dev/null 2>&1 || ! diff -q go.sum go.sum.backup >/dev/null 2>&1; then
        echo "go.mod or go.sum is not tidy"
        echo "Run: go mod tidy"
        mv go.mod.backup go.mod
        mv go.sum.backup go.sum
        exit 1
    fi
    rm go.mod.backup go.sum.backup
'

# 5. Unit Tests
run_check "Unit Tests" "go test -v ./..."

# 6. Unit Tests with Race Detection
run_check "Race Detection Tests" "go test -race ./..."

# 7. Test Coverage
run_check "Test Coverage Check" '
    go test -coverprofile=coverage.out ./... >/dev/null
    COVERAGE=$(go tool cover -func=coverage.out | grep total | awk "{print \$3}" | sed "s/%//")
    echo "Total coverage: ${COVERAGE}%"
    
    # Optional: Enforce minimum coverage (currently set to 0 for sample project)
    THRESHOLD=0
    if [ $(echo "$COVERAGE < $THRESHOLD" | bc 2>/dev/null || echo 0) -eq 1 ]; then
        echo "Coverage ${COVERAGE}% is below threshold ${THRESHOLD}%"
        rm coverage.out
        exit 1
    fi
    rm coverage.out
'

# 8. Build Check
run_check "Build Verification" "go build -o /tmp/test-build cmd/api/main.go && rm /tmp/test-build"

# 9. Library Version Check (Main Branch Only)
if [ "$(git rev-parse --abbrev-ref HEAD)" = "main" ]; then
    run_check "Library Version Check (Main Branch)" '
        if grep -q "^[^#]*replace.*golang-lib" go.mod; then
            echo "❌ ERROR: Main branch cannot use \"replace\" directive"
            echo "Main branch must use a tagged version"
            echo ""
            echo "Current go.mod:"
            grep -A 2 -B 2 "replace.*golang-lib" go.mod || true
            echo ""
            echo "Fix: Remove replace directive and use:"
            echo "  go get github.com/bikashb-meesho/golang-lib@vX.Y.Z"
            exit 1
        fi
        echo "✓ No replace directive found"
    '
fi

# 10. Check for Common Issues
run_check "Common Issues Check" '
    # Check for debug print statements
    if git diff --cached --name-only | xargs grep -n "fmt.Println\|log.Println" 2>/dev/null; then
        echo "⚠️  Warning: Found debug print statements"
        echo "Consider using the logger instead"
    fi
    
    # Check for TODO comments
    TODO_COUNT=$(git diff --cached --name-only | xargs grep -c "TODO\|FIXME" 2>/dev/null | awk -F: "{sum += \$2} END {print sum}")
    if [ "$TODO_COUNT" -gt 0 ]; then
        echo "ℹ️  Found $TODO_COUNT TODO/FIXME comments"
    fi
    
    exit 0  # These are warnings, not failures
'

# Summary
echo ""
echo -e "${BLUE}================================================${NC}"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! Safe to commit.${NC}"
    echo -e "${BLUE}================================================${NC}"
    exit 0
else
    echo -e "${RED}❌ Some checks failed. Please fix before committing.${NC}"
    echo -e "${BLUE}================================================${NC}"
    exit 1
fi

