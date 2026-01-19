package com.payment.redis.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.payment.redis.domain.Transaction;
import io.micronaut.core.annotation.Introspected;

import java.math.BigDecimal;
import java.time.Instant;

/**
 * Response DTO for transactions (includes status and timestamps)
 */
@Introspected
public class TransactionResponse {
    @JsonProperty("_id")
    private String id;
    
    private String reference;
    private String name;
    private String email;
    private BigDecimal amount;
    private BigDecimal amountReceived;
    private String school;
    private String senderFullName;
    private String countryFrom;
    private String senderAddress;
    private String currencyFrom;
    private String studentId;
    private String status;
    private BigDecimal feePercentage;
    private BigDecimal feeAmount;
    private BigDecimal finalAmount;
    private Instant createdAt;
    private Instant updatedAt;

    public TransactionResponse() {
    }

    public TransactionResponse(String id, String reference, String name, String email,
                              BigDecimal amount, BigDecimal amountReceived, String school,
                              String senderFullName, String countryFrom, String senderAddress,
                              String currencyFrom, String studentId, String status,
                              BigDecimal feePercentage, BigDecimal feeAmount, BigDecimal finalAmount,
                              Instant createdAt, Instant updatedAt) {
        this.id = id;
        this.reference = reference;
        this.name = name;
        this.email = email;
        this.amount = amount;
        this.amountReceived = amountReceived;
        this.school = school;
        this.senderFullName = senderFullName;
        this.countryFrom = countryFrom;
        this.senderAddress = senderAddress;
        this.currencyFrom = currencyFrom;
        this.studentId = studentId;
        this.status = status;
        this.feePercentage = feePercentage;
        this.feeAmount = feeAmount;
        this.finalAmount = finalAmount;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    /**
     * Convert from Transaction domain object to DTO
     */
    public static TransactionResponse fromTransaction(Transaction transaction) {
        return new TransactionResponse(
            transaction.getId(),
            transaction.getReference(),
            transaction.getName(),
            transaction.getEmail(),
            transaction.getAmount(),
            transaction.getAmountReceived(),
            transaction.getSchool(),
            transaction.getSenderFullName(),
            transaction.getCountryFrom(),
            transaction.getSenderAddress(),
            transaction.getCurrencyFrom(),
            transaction.getStudentId(),
            transaction.getStatus(),
            transaction.getFeePercentage(),
            transaction.getFeeAmount(),
            transaction.getFinalAmount(),
            transaction.getCreatedAt(),
            transaction.getUpdatedAt()
        );
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getReference() { return reference; }
    public void setReference(String reference) { this.reference = reference; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public BigDecimal getAmountReceived() { return amountReceived; }
    public void setAmountReceived(BigDecimal amountReceived) { this.amountReceived = amountReceived; }

    public String getSchool() { return school; }
    public void setSchool(String school) { this.school = school; }

    public String getSenderFullName() { return senderFullName; }
    public void setSenderFullName(String senderFullName) { this.senderFullName = senderFullName; }

    public String getCountryFrom() { return countryFrom; }
    public void setCountryFrom(String countryFrom) { this.countryFrom = countryFrom; }

    public String getSenderAddress() { return senderAddress; }
    public void setSenderAddress(String senderAddress) { this.senderAddress = senderAddress; }

    public String getCurrencyFrom() { return currencyFrom; }
    public void setCurrencyFrom(String currencyFrom) { this.currencyFrom = currencyFrom; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public BigDecimal getFeePercentage() { return feePercentage; }
    public void setFeePercentage(BigDecimal feePercentage) { this.feePercentage = feePercentage; }

    public BigDecimal getFeeAmount() { return feeAmount; }
    public void setFeeAmount(BigDecimal feeAmount) { this.feeAmount = feeAmount; }

    public BigDecimal getFinalAmount() { return finalAmount; }
    public void setFinalAmount(BigDecimal finalAmount) { this.finalAmount = finalAmount; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
