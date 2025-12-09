#!/bin/bash
# Quick script to check MySQL and Redis data on OCI VM

VM_IP="152.70.200.104"

echo "=== Checking MySQL Data ==="
ssh ubuntu@$VM_IP << 'EOF'
docker exec mysql mysql -uroot -p${DB_PASSWORD:-ChangeMe123!} hermes_payments -e "
SELECT 
  id, 
  reference, 
  name, 
  email, 
  amount, 
  amount_received, 
  status, 
  created_at 
FROM payments 
ORDER BY created_at DESC 
LIMIT 10;
"
EOF

echo ""
echo "=== Checking Redis Cache ==="
ssh ubuntu@$VM_IP << 'EOF'
echo "Redis Keys:"
docker exec redis redis-cli KEYS '*'

echo ""
echo "Cache TTL:"
docker exec redis redis-cli TTL 'payments:all'

echo ""
echo "Redis Memory Usage:"
docker exec redis redis-cli INFO memory | grep used_memory_human
EOF

echo ""
echo "=== Database Statistics ==="
ssh ubuntu@$VM_IP << 'EOF'
docker exec mysql mysql -uroot -p${DB_PASSWORD:-ChangeMe123!} hermes_payments -e "
SELECT 
  COUNT(*) as total_payments,
  SUM(amount) as total_amount,
  AVG(amount) as avg_amount,
  COUNT(DISTINCT status) as unique_statuses
FROM payments;
"
EOF
