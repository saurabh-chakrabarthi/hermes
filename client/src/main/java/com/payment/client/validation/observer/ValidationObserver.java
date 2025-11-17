package com.payment.client.validation.observer;

import com.payment.client.domain.Payment;
import com.payment.client.domain.ValidationResult;

/**
 * Observer pattern interface for validation events
 */
public interface ValidationObserver {
    void onValidationComplete(Payment payment, ValidationResult result);
    void onValidationFailed(Payment payment, ValidationResult result);
}