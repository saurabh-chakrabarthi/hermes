package com.payment.client.validation;

import com.payment.client.domain.Payment;
import com.payment.client.domain.ValidationResult;
import java.util.List;

/**
 * Template Method pattern for common validation logic
 */
public abstract class AbstractValidationRule implements ValidationRule {
    
    @Override
    public final ValidationResult validate(Payment payment, List<Payment> existingPayments) {
        if (payment == null) {
            return createInvalidResult("Payment cannot be null");
        }
        return performValidation(payment, existingPayments);
    }
    
    protected abstract ValidationResult performValidation(Payment payment, List<Payment> existingPayments);
    
    protected ValidationResult createValidResult(String message) {
        return ValidationResult.builder()
                .valid(true)
                .errorType(ValidationResult.ValidationErrorType.NONE)
                .message(message)
                .build();
    }
    
    protected ValidationResult createInvalidResult(String message, ValidationResult.ValidationErrorType errorType) {
        return ValidationResult.builder()
                .valid(false)
                .errorType(errorType)
                .message(message)
                .build();
    }
    
    protected ValidationResult createInvalidResult(String message) {
        return createInvalidResult(message, ValidationResult.ValidationErrorType.NONE);
    }
}