package com.payment.redis.controller;

import com.payment.redis.domain.Transaction;
import com.payment.redis.dto.CreateTransactionRequest;
import com.payment.redis.dto.TransactionResponse;
import com.payment.redis.service.TransactionService;
import io.micronaut.http.annotation.*;
import io.micronaut.http.HttpStatus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * REST API Controller for Transaction management
 */
@Controller("/api/transactions")
public class TransactionController {
    private static final Logger log = LoggerFactory.getLogger(TransactionController.class);
    private final TransactionService transactionService;

    public TransactionController(TransactionService transactionService) {
        this.transactionService = transactionService;
    }

    /**
     * Get all transactions
     */
    @Get
    public List<TransactionResponse> getAllTransactions() {
        log.info("Fetching all transactions");
        List<Transaction> transactions = transactionService.getAllTransactions();
        return transactions.stream()
            .map(TransactionResponse::fromTransaction)
            .collect(Collectors.toList());
    }

    /**
     * Get transaction by ID
     */
    @Get("/{id}")
    public TransactionResponse getTransactionById(@PathVariable String id) {
        log.info("Fetching transaction: {}", id);
        return transactionService.getTransactionById(id)
            .map(TransactionResponse::fromTransaction)
            .orElseThrow(() -> new TransactionNotFoundException("Transaction not found: " + id));
    }

    /**
     * Create a new transaction
     */
    @Post
    @Status(HttpStatus.CREATED)
    public TransactionResponse createTransaction(@Body CreateTransactionRequest request) {
        log.info("Creating new transaction for: {}", request.getEmail());
        
        Transaction transaction = transactionService.createTransaction(
            request.getName(),
            request.getEmail(),
            request.getAmount(),
            request.getSchool(),
            request.getCountryFrom(),
            request.getSenderAddress(),
            request.getCurrencyFrom(),
            request.getStudentId()
        );
        
        return TransactionResponse.fromTransaction(transaction);
    }

    /**
     * Get transaction by reference number
     */
    @Get("/reference/{reference}")
    public TransactionResponse getByReference(@PathVariable String reference) {
        log.info("Fetching transaction by reference: {}", reference);
        return transactionService.getTransactionByReference(reference)
            .map(TransactionResponse::fromTransaction)
            .orElseThrow(() -> new TransactionNotFoundException("Transaction not found: " + reference));
    }

    /**
     * Delete transaction
     */
    @Delete("/{id}")
    public Map<String, String> deleteTransaction(@PathVariable String id) {
        log.info("Deleting transaction: {}", id);
        boolean deleted = transactionService.deleteTransaction(id);
        
        if (deleted) {
            return Map.of("message", "Transaction deleted successfully");
        } else {
            throw new TransactionNotFoundException("Transaction not found: " + id);
        }
    }

    /**
     * Get transaction statistics
     */
    @Get("/stats/count")
    public Map<String, Long> getTransactionCount() {
        log.info("Fetching transaction count");
        return Map.of("total", transactionService.getTransactionCount());
    }

    /**
     * Custom exception
     */
    public static class TransactionNotFoundException extends RuntimeException {
        public TransactionNotFoundException(String message) {
            super(message);
        }
    }
}
