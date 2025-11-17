package com.payment.client.domain;

/**
 * Enum for payment status using State pattern concept
 */
public enum PaymentStatus {
    EXACT("Payment matches expected amount"),
    OVERPAYMENT("Payment exceeds expected amount"),
    UNDERPAYMENT("Payment is below expected amount");
    
    private final String description;
    
    PaymentStatus(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}