package com.payment.dashboard.dto;

import io.micronaut.serde.annotation.Serdeable;
import java.math.BigDecimal;

@Serdeable
public class BookingDTO {
    private String reference;
    private BigDecimal amount;
    private BigDecimal amountReceived;
    private String countryFrom;
    private String senderFullName;
    private String senderAddress;
    private String school;
    private String currencyFrom;
    private String studentId;
    private String email;

    public String getReference() { return reference; }
    public void setReference(String reference) { this.reference = reference; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public BigDecimal getAmountReceived() { return amountReceived; }
    public void setAmountReceived(BigDecimal amountReceived) { this.amountReceived = amountReceived; }

    public String getCountryFrom() { return countryFrom; }
    public void setCountryFrom(String countryFrom) { this.countryFrom = countryFrom; }

    public String getSenderFullName() { return senderFullName; }
    public void setSenderFullName(String senderFullName) { this.senderFullName = senderFullName; }

    public String getSenderAddress() { return senderAddress; }
    public void setSenderAddress(String senderAddress) { this.senderAddress = senderAddress; }

    public String getSchool() { return school; }
    public void setSchool(String school) { this.school = school; }

    public String getCurrencyFrom() { return currencyFrom; }
    public void setCurrencyFrom(String currencyFrom) { this.currencyFrom = currencyFrom; }

    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
