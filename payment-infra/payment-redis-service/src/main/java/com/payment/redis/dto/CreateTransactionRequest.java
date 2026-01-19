package com.payment.redis.dto;

import io.micronaut.core.annotation.Introspected;

import java.math.BigDecimal;

/**
 * Request DTO for creating a transaction
 */
@Introspected
public class CreateTransactionRequest {
    private String name;
    private String email;
    private BigDecimal amount;
    private String school;
    private String countryFrom;
    private String senderAddress;
    private String currencyFrom;
    private String studentId;

    public CreateTransactionRequest() {
    }

    public CreateTransactionRequest(String name, String email, BigDecimal amount,
                                    String school, String countryFrom, String senderAddress,
                                    String currencyFrom, String studentId) {
        this.name = name;
        this.email = email;
        this.amount = amount;
        this.school = school;
        this.countryFrom = countryFrom;
        this.senderAddress = senderAddress;
        this.currencyFrom = currencyFrom;
        this.studentId = studentId;
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

    public String getSchool() {
        return school;
    }

    public void setSchool(String school) {
        this.school = school;
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
}
