package com.payment.client.validation;

import com.payment.client.domain.Payment;
import com.payment.client.domain.ValidationResult;
import java.util.List;

/**
 * Chain of Responsibility pattern for validation processing
 */
public abstract class ValidationChain {
    private ValidationChain nextChain;
    
    public ValidationChain setNext(ValidationChain nextChain) {
        this.nextChain = nextChain;
        return nextChain;
    }
    
    public ValidationResult process(Payment payment, List<Payment> existingPayments) {
        ValidationResult result = validate(payment, existingPayments);
        
        if (!result.isValid() || nextChain == null) {
            return result;
        }
        
        return nextChain.process(payment, existingPayments);
    }
    
    protected abstract ValidationResult validate(Payment payment, List<Payment> existingPayments);
}