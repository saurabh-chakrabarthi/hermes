package com.payment.redis.domain;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.micronaut.core.annotation.Introspected;

import java.math.BigDecimal;
import java.time.Instant;

/**
 * Transaction/Payment domain model representing a payment transaction stored in Redis.
 * Schema in Redis: payment:{uuid}:* (hash)
 */
@Introspected
public class Transaction {
    @JsonProperty("_id")
    private String id;
    
    private String reference;           // REF001, REF002, etc.
    private String name;                // Sender name
    private String email;               // Sender email
    private BigDecimal amount;          // Tuition/remittance amount
    private BigDecimal amountReceived;  // Actual amount received
    private String school;              // Institution name
    private String senderFullName;      // Full name of sender
    private String countryFrom;         // Country of origin
    private String senderAddress;       // Sender's address
    private String currencyFrom;        // Source currency
    private String studentId;           // Student ID
    
    // Status: EXACT, UNDERPAYMENT, OVERPAYMENT
    private String status;              
    private BigDecimal feePercentage;   // Fee percentage applied
    private BigDecimal feeAmount;       // Calculated fee
    private BigDecimal finalAmount;     // Amount + fee
    
    private Instant createdAt;
    private Instant updatedAt;

    // Constructors
    public Transaction() {
    }

    public Transaction(String id, String reference, String name, String email, 
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

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getReference() {
        return reference;
    }

    public void setReference(String reference) {
        this.reference = reference;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public BigDecimal getAmountReceived() {
        return amountReceived;
    }

    public void setAmountReceived(BigDecimal amountReceived) {
        this.amountReceived = amountReceived;
    }

    public String getSchool() {
        return school;
    }

    public void setSchool(String school) {
        this.school = school;
    }

    public String getSenderFullName() {
        return senderFullName;
    }

    public void setSenderFullName(String senderFullName) {
        this.senderFullName = senderFullName;
    }

    public String getCountryFrom() {
        return countryFrom;
    }

    public void setCountryFrom(String countryFrom) {
        this.countryFrom = countryFrom;
    }

    public String getSenderAddress() {
        return senderAddress;
    }

    public void setSenderAddress(String senderAddress) {
        this.senderAddress = senderAddress;
    }

    public String getCurrencyFrom() {
        return currencyFrom;
    }

    public void setCurrencyFrom(String currencyFrom) {
        this.currencyFrom = currencyFrom;
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getFeePercentage() {
        return feePercentage;
    }

    public void setFeePercentage(BigDecimal feePercentage) {
        this.feePercentage = feePercentage;
    }

    public BigDecimal getFeeAmount() {
        return feeAmount;
    }

    public void setFeeAmount(BigDecimal feeAmount) {
        this.feeAmount = feeAmount;
    }

    public BigDecimal getFinalAmount() {
        return finalAmount;
    }

    public void setFinalAmount(BigDecimal finalAmount) {
        this.finalAmount = finalAmount;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "Transaction{" +
                "id='" + id + '\'' +
                ", reference='" + reference + '\'' +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", amount=" + amount +
                ", amountReceived=" + amountReceived +
                ", school='" + school + '\'' +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
