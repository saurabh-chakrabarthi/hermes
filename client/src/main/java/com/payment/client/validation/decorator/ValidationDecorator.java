package com.payment.client.validation.decorator;

import com.payment.client.domain.Payment;
import com.payment.client.domain.ValidationResult;
import com.payment.client.validation.ValidationRule;
import java.util.List;

/**
 * Decorator pattern for adding additional behavior to validation rules
 */
public abstract class ValidationDecorator implements ValidationRule {
    protected final ValidationRule wrappedRule;
    
    public ValidationDecorator(ValidationRule rule) {
        this.wrappedRule = rule;
    }
    
    @Override
    public ValidationResult validate(Payment payment, List<Payment> existingPayments) {
        return wrappedRule.validate(payment, existingPayments);
    }
    
    @Override
    public String getRuleName() {
        return wrappedRule.getRuleName();
    }
}