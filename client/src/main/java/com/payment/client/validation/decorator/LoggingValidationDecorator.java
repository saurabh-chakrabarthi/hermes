package com.payment.client.validation.decorator;

import com.payment.client.domain.Payment;
import com.payment.client.domain.ValidationResult;
import com.payment.client.validation.ValidationRule;
import lombok.extern.slf4j.Slf4j;
import java.util.List;

/**
 * Concrete decorator that adds logging to validation rules
 */
@Slf4j
public class LoggingValidationDecorator extends ValidationDecorator {
    
    public LoggingValidationDecorator(ValidationRule rule) {
        super(rule);
    }
    
    @Override
    public ValidationResult validate(Payment payment, List<Payment> existingPayments) {
        log.info("Starting validation: {} for payment reference: {}", getRuleName(), payment.getReference());
        
        ValidationResult result = super.validate(payment, existingPayments);
        
        if (result.isValid()) {
            log.info("Validation passed: {} for payment reference: {}", getRuleName(), payment.getReference());
        } else {
            log.warn("Validation failed: {} for payment reference: {} - {}", 
                    getRuleName(), payment.getReference(), result.getMessage());
        }
        
        return result;
    }
}