package com.payment.client.validation;

import com.payment.client.domain.Payment;
import com.payment.client.domain.ValidationResult;
import java.util.List;

/**
 * Strategy interface for payment validation rules
 */
public interface ValidationRule {
    ValidationResult validate(Payment payment, List<Payment> existingPayments);
    String getRuleName();
}