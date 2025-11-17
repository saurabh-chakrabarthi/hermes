package com.payment.client.service;

import com.payment.client.domain.Payment;
import com.payment.client.domain.PaymentValidationResult;
import com.payment.client.validation.ValidationEngine;
import org.springframework.stereotype.Service;
import java.util.List;

/**
 * Refactored service using new validation architecture
 * Demonstrates Dependency Injection and Single Responsibility Principle
 */
@Service
public class RefactoredPaymentValidationService {
    private final ValidationEngine validationEngine;
    
    public RefactoredPaymentValidationService(ValidationEngine validationEngine) {
        this.validationEngine = validationEngine;
    }
    
    public PaymentValidationResult validatePayment(Payment payment, List<Payment> existingPayments) {
        return validationEngine.validatePayment(payment, existingPayments);
    }
}