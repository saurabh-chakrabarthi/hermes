#!/bin/bash

# Hermes Payment Portal - Structure Verification Script
# This script verifies the refactored project structure

set -e

echo "================================"
echo "Hermes Payment Portal Verification"
echo "================================"
echo ""

PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$PROJECT_ROOT"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1 (MISSING)"
        return 1
    fi
}

# Function to check directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
        return 0
    else
        echo -e "${RED}✗${NC} $1/ (MISSING)"
        return 1
    fi
}

errors=0

echo "=== Core Structure ==="
check_file "pom.xml" || ((errors++))
check_dir "payment-dashboard" || ((errors++))
check_dir "payment-portal" || ((errors++))
check_dir "payment-infra/payment-redis-service" || ((errors++))

echo ""
echo "=== Payment Dashboard ==="
check_file "payment-dashboard/pom.xml" || ((errors++))
check_dir "payment-dashboard/src/main/java/com/payment/dashboard" || ((errors++))
check_file "payment-dashboard/src/main/resources/application.yml" || ((errors++))

echo ""
echo "=== Payment Portal ==="
check_file "payment-portal/package.json" || ((errors++))
check_file "payment-portal/server.js" || ((errors++))
check_file "payment-portal/Dockerfile" || ((errors++))

echo ""
echo "=== Payment Redis Service ==="
check_file "payment-infra/payment-redis-service/pom.xml" || ((errors++))
check_file "payment-infra/payment-redis-service/Dockerfile" || ((errors++))
check_dir "payment-infra/payment-redis-service/src/main/java/com/payment/redis" || ((errors++))
check_file "payment-infra/payment-redis-service/src/main/resources/application.yml" || ((errors++))

echo ""
echo "=== Redis Service Components ==="
check_file "payment-infra/payment-redis-service/src/main/java/com/payment/redis/Application.java" || ((errors++))
check_file "payment-infra/payment-redis-service/src/main/java/com/payment/redis/controller/TransactionController.java" || ((errors++))
check_file "payment-infra/payment-redis-service/src/main/java/com/payment/redis/service/TransactionService.java" || ((errors++))
check_file "payment-infra/payment-redis-service/src/main/java/com/payment/redis/repository/TransactionRepository.java" || ((errors++))
check_file "payment-infra/payment-redis-service/src/main/java/com/payment/redis/domain/Transaction.java" || ((errors++))

echo ""
echo "=== Docker Configuration ==="
check_file "payment-infra/Dockerfile" || ((errors++))
check_file "payment-infra/docker/docker-compose.dev.yml" || ((errors++))
check_file "payment-infra/docker/docker-compose.yml" || ((errors++))

echo ""
echo "=== Verification Summary ==="
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Project structure is correct. You can now:"
    echo "1. Build: mvn clean install"
    echo "2. Test: cd payment-infra/docker && docker-compose -f docker-compose.dev.yml up -d"
    echo "3. Review: Open QUICKSTART.md for quick commands"
    exit 0
else
    echo -e "${RED}✗ Found $errors missing files/directories${NC}"
    echo "" Docker image: docker build -f payment-infra/Dockerfile -t payment-dashboard ."
    echo "2. Start services: docker-compose -f payment-infra/docker/docker-compose.yml up -d"
    echo "3. View logs: docker-compose -f payment-infra/docker/docker-compose.yml logs -f
fi
