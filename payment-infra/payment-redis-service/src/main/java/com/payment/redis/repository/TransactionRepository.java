package com.payment.redis.repository;

import com.payment.redis.domain.Transaction;
import io.lettuce.core.api.StatefulRedisConnection;
import io.lettuce.core.api.sync.RedisCommands;
import jakarta.inject.Singleton;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Repository for managing Transaction data in Redis.
 * 
 * Redis Schema:
 * - payment:{uuid} (hash) - stores transaction data
 * - payment:counter (string) - stores sequential counter for reference numbers
 * - audit:{uuid} (hash) - stores audit log entries
 * 
 * Index Lists:
 * - payment:all (list) - list of all payment IDs for efficient retrieval
 */
@Singleton
public class TransactionRepository {
    private static final Logger log = LoggerFactory.getLogger(TransactionRepository.class);
    private static final String PAYMENT_KEY_PREFIX = "payment:";
    private static final String COUNTER_KEY = "payment:counter";
    private static final String ALL_PAYMENTS_KEY = "payment:all";
    private static final String AUDIT_KEY_PREFIX = "audit:";

    private final StatefulRedisConnection<String, String> connection;

    public TransactionRepository(StatefulRedisConnection<String, String> connection) {
        this.connection = connection;
    }

    /**
     * Save a transaction to Redis
     */
    public void save(Transaction transaction) {
        try {
            RedisCommands<String, String> commands = connection.sync();
            String key = PAYMENT_KEY_PREFIX + transaction.getId();
            
            // Create hash map from transaction
            Map<String, String> transactionMap = transactionToMap(transaction);
            
            // Store transaction as hash
            commands.hset(key, transactionMap);
            
            // Add to index list
            commands.rpush(ALL_PAYMENTS_KEY, transaction.getId());
            
            // Set expiration (optional - e.g., 1 year)
            commands.expire(key, 365 * 24 * 60 * 60);
            
            log.info("✅ Transaction saved: {}", transaction.getId());
        } catch (Exception e) {
            log.error("❌ Error saving transaction", e);
            throw new RuntimeException("Failed to save transaction", e);
        }
    }

    /**
     * Find a transaction by ID
     */
    public Optional<Transaction> findById(String id) {
        try {
            RedisCommands<String, String> commands = connection.sync();
            String key = PAYMENT_KEY_PREFIX + id;
            
            Map<String, String> data = commands.hgetall(key);
            if (data.isEmpty()) {
                return Optional.empty();
            }
            
            return Optional.of(mapToTransaction(data));
        } catch (Exception e) {
            log.error("❌ Error finding transaction by ID", e);
            return Optional.empty();
        }
    }

    /**
     * Find transaction by reference number
     */
    public Optional<Transaction> findByReference(String reference) {
        try {
            RedisCommands<String, String> commands = connection.sync();
            List<String> paymentIds = commands.lrange(ALL_PAYMENTS_KEY, 0, -1);
            
            for (String id : paymentIds) {
                String key = PAYMENT_KEY_PREFIX + id;
                Map<String, String> data = commands.hgetall(key);
                if (reference.equals(data.get("reference"))) {
                    return Optional.of(mapToTransaction(data));
                }
            }
            
            return Optional.empty();
        } catch (Exception e) {
            log.error("❌ Error finding transaction by reference", e);
            return Optional.empty();
        }
    }

    /**
     * Get all transactions sorted by createdAt (newest first)
     */
    public List<Transaction> findAll() {
        try {
            RedisCommands<String, String> commands = connection.sync();
            List<String> paymentIds = commands.lrange(ALL_PAYMENTS_KEY, 0, -1);
            
            List<Transaction> transactions = new ArrayList<>();
            for (String id : paymentIds) {
                String key = PAYMENT_KEY_PREFIX + id;
                Map<String, String> data = commands.hgetall(key);
                if (!data.isEmpty()) {
                    transactions.add(mapToTransaction(data));
                }
            }
            
            // Sort by createdAt descending
            transactions.sort((t1, t2) -> t2.getCreatedAt().compareTo(t1.getCreatedAt()));
            
            return transactions;
        } catch (Exception e) {
            log.error("❌ Error fetching all transactions", e);
            return Collections.emptyList();
        }
    }

    /**
     * Get next reference number
     */
    public String getNextReference() {
        try {
            RedisCommands<String, String> commands = connection.sync();
            Long count = commands.incr(COUNTER_KEY);
            return "REF" + String.format("%03d", count);
        } catch (Exception e) {
            log.error("❌ Error getting next reference number", e);
            throw new RuntimeException("Failed to get next reference number", e);
        }
    }

    /**
     * Delete a transaction by ID
     */
    public boolean deleteById(String id) {
        try {
            RedisCommands<String, String> commands = connection.sync();
            String key = PAYMENT_KEY_PREFIX + id;
            
            Long deleted = commands.del(key);
            if (deleted > 0) {
                commands.lrem(ALL_PAYMENTS_KEY, 1, id);
                log.info("✅ Transaction deleted: {}", id);
                return true;
            }
            return false;
        } catch (Exception e) {
            log.error("❌ Error deleting transaction", e);
            return false;
        }
    }

    /**
     * Update a transaction
     */
    public void update(Transaction transaction) {
        transaction.setUpdatedAt(Instant.now());
        save(transaction);
    }

    /**
     * Get count of all transactions
     */
    public long count() {
        try {
            RedisCommands<String, String> commands = connection.sync();
            return commands.llen(ALL_PAYMENTS_KEY);
        } catch (Exception e) {
            log.error("❌ Error counting transactions", e);
            return 0;
        }
    }

    /**
     * Save audit log entry
     */
    public void saveAuditLog(String paymentId, String action, String details) {
        try {
            RedisCommands<String, String> commands = connection.sync();
            String auditId = UUID.randomUUID().toString();
            String key = AUDIT_KEY_PREFIX + auditId;
            
            Map<String, String> auditMap = new HashMap<>();
            auditMap.put("paymentId", paymentId);
            auditMap.put("action", action);
            auditMap.put("details", details);
            auditMap.put("createdAt", Instant.now().toString());
            
            commands.hset(key, auditMap);
            commands.expire(key, 365 * 24 * 60 * 60);
            
            log.info("✅ Audit log saved: {} for transaction: {}", action, paymentId);
        } catch (Exception e) {
            log.error("❌ Error saving audit log", e);
        }
    }

    /**
     * Convert Transaction object to Map for Redis storage
     */
    private Map<String, String> transactionToMap(Transaction t) {
        Map<String, String> map = new HashMap<>();
        map.put("_id", t.getId());
        map.put("reference", t.getReference());
        map.put("name", t.getName());
        map.put("email", t.getEmail());
        map.put("amount", t.getAmount().toString());
        map.put("amountReceived", t.getAmountReceived().toString());
        map.put("school", t.getSchool());
        map.put("senderFullName", t.getSenderFullName());
        map.put("countryFrom", t.getCountryFrom());
        map.put("senderAddress", t.getSenderAddress());
        map.put("currencyFrom", t.getCurrencyFrom());
        map.put("studentId", t.getStudentId());
        map.put("status", t.getStatus());
        map.put("feePercentage", t.getFeePercentage().toString());
        map.put("feeAmount", t.getFeeAmount().toString());
        map.put("finalAmount", t.getFinalAmount().toString());
        map.put("createdAt", t.getCreatedAt().toString());
        map.put("updatedAt", t.getUpdatedAt().toString());
        return map;
    }

    /**
     * Convert Redis Map to Transaction object
     */
    private Transaction mapToTransaction(Map<String, String> map) {
        Transaction t = new Transaction();
        t.setId(map.get("_id"));
        t.setReference(map.get("reference"));
        t.setName(map.get("name"));
        t.setEmail(map.get("email"));
        t.setAmount(new BigDecimal(map.getOrDefault("amount", "0")));
        t.setAmountReceived(new BigDecimal(map.getOrDefault("amountReceived", "0")));
        t.setSchool(map.get("school"));
        t.setSenderFullName(map.get("senderFullName"));
        t.setCountryFrom(map.get("countryFrom"));
        t.setSenderAddress(map.get("senderAddress"));
        t.setCurrencyFrom(map.get("currencyFrom"));
        t.setStudentId(map.get("studentId"));
        t.setStatus(map.get("status"));
        t.setFeePercentage(new BigDecimal(map.getOrDefault("feePercentage", "0")));
        t.setFeeAmount(new BigDecimal(map.getOrDefault("feeAmount", "0")));
        t.setFinalAmount(new BigDecimal(map.getOrDefault("finalAmount", "0")));
        t.setCreatedAt(Instant.parse(map.get("createdAt")));
        t.setUpdatedAt(Instant.parse(map.get("updatedAt")));
        return t;
    }
}
