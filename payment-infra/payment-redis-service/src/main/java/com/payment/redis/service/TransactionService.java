package com.payment.redis.service;

import com.payment.redis.domain.Transaction;
import com.payment.redis.repository.TransactionRepository;
import jakarta.inject.Singleton;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Business logic service for managing transactions
 */
@Singleton
public class TransactionService {
    private static final Logger log = LoggerFactory.getLogger(TransactionService.class);
    private final TransactionRepository repository;

    public TransactionService(TransactionRepository repository) {
        this.repository = repository;
    }

    /**
     * Create a new transaction with automatic fee calculation and amount received
     */
    public Transaction createTransaction(String name, String email, BigDecimal amount,
                                        String school, String countryFrom, String senderAddress,
                                        String currencyFrom, String studentId) {
        try {
            // Generate ID and reference
            String id = UUID.randomUUID().toString();
            String reference = repository.getNextReference();
            
            // Simulate amount received (80-120% of requested amount)
            double randomFactor = 0.8 + (Math.random() * 0.4);
            BigDecimal amountReceived = amount.multiply(
                BigDecimal.valueOf(randomFactor)
            ).setScale(2, RoundingMode.HALF_UP);
            
            // Calculate fee based on amount
            BigDecimal feePercentage = calculateFeePercentage(amount);
            BigDecimal feeAmount = amount.multiply(feePercentage)
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
            BigDecimal finalAmount = amount.add(feeAmount);
            
            // Determine status
            String status = determineStatus(amount, amountReceived);
            
            Instant now = Instant.now();
            
            Transaction transaction = new Transaction(
                id, reference, name, email, amount, amountReceived,
                school, name, countryFrom, senderAddress, currencyFrom, studentId,
                status, feePercentage, feeAmount, finalAmount,
                now, now
            );
            
            // Save to Redis
            repository.save(transaction);
            
            // Log audit
            repository.saveAuditLog(id, "CREATE", "Transaction created");
            
            log.info("✅ Transaction created: {} with reference: {}", id, reference);
            return transaction;
        } catch (Exception e) {
            log.error("❌ Error creating transaction", e);
            throw new RuntimeException("Failed to create transaction", e);
        }
    }

    /**
     * Get all transactions
     */
    public List<Transaction> getAllTransactions() {
        return repository.findAll();
    }

    /**
     * Get transaction by ID
     */
    public Optional<Transaction> getTransactionById(String id) {
        return repository.findById(id);
    }

    /**
     * Get transaction by reference number
     */
    public Optional<Transaction> getTransactionByReference(String reference) {
        return repository.findByReference(reference);
    }

    /**
     * Delete transaction
     */
    public boolean deleteTransaction(String id) {
        boolean deleted = repository.deleteById(id);
        if (deleted) {
            repository.saveAuditLog(id, "DELETE", "Transaction deleted");
        }
        return deleted;
    }

    /**
     * Get total transaction count
     */
    public long getTransactionCount() {
        return repository.count();
    }

    /**
     * Calculate fee percentage based on amount
     */
    private BigDecimal calculateFeePercentage(BigDecimal amount) {
        if (amount.compareTo(BigDecimal.valueOf(50000)) > 0) {
            return BigDecimal.valueOf(5.0);
        } else if (amount.compareTo(BigDecimal.valueOf(30000)) > 0) {
            return BigDecimal.valueOf(3.0);
        } else {
            return BigDecimal.valueOf(2.0);
        }
    }

    /**
     * Determine transaction status based on amount received
     */
    private String determineStatus(BigDecimal amount, BigDecimal amountReceived) {
        int comparison = amountReceived.compareTo(amount);
        if (comparison < 0) {
            return "UNDERPAYMENT";
        } else if (comparison > 0) {
            return "OVERPAYMENT";
        } else {
            return "EXACT";
        }
    }
}
