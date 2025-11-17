package com.payment.client.domain.builder;

import com.payment.client.domain.Payment;
import java.math.BigDecimal;

/**
 * Builder pattern implementation for Payment creation
 * Demonstrates Fluent Interface and Method Chaining
 */
public class PaymentBuilder {
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
    
    public static PaymentBuilder newPayment() {
        return new PaymentBuilder();
    }
    
    public PaymentBuilder withReference(String reference) {
        this.reference = reference;
        return this;
    }
    
    public PaymentBuilder withAmount(BigDecimal amount) {
        this.amount = amount;
        return this;
    }
    
    public PaymentBuilder withAmountReceived(BigDecimal amountReceived) {
        this.amountReceived = amountReceived;
        return this;
    }
    
    public PaymentBuilder withEmail(String email) {
        this.email = email;
        return this;
    }
    
    public PaymentBuilder withSender(String fullName, String address) {
        this.senderFullName = fullName;
        this.senderAddress = address;
        return this;
    }
    
    public PaymentBuilder withDetails(String countryFrom, String school, String currencyFrom, String studentId) {
        this.countryFrom = countryFrom;
        this.school = school;
        this.currencyFrom = currencyFrom;
        this.studentId = studentId;
        return this;
    }
    
    public Payment build() {
        return Payment.builder()
                .reference(reference)
                .amount(amount)
                .amountReceived(amountReceived)
                .countryFrom(countryFrom)
                .senderFullName(senderFullName)
                .senderAddress(senderAddress)
                .school(school)
                .currencyFrom(currencyFrom)
                .studentId(studentId)
                .email(email)
                .build();
    }
}