package com.payment.client.validation;

import com.payment.client.domain.Payment;
import com.payment.client.domain.PaymentValidationResult;
import com.payment.client.domain.ValidationResult;
import com.payment.client.domain.FeeCalculation;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Facade pattern for validation orchestration
 */
@Service
public class ValidationEngine {
    private final List<ValidationRule> validationRules;
    
    public ValidationEngine(List<ValidationRule> validationRules) {
        this.validationRules = validationRules;
    }
    
    public PaymentValidationResult validatePayment(Payment payment, List<Payment> existingPayments) {
        Map<String, ValidationResult> results = validationRules.stream()
                .collect(Collectors.toMap(
                    ValidationRule::getRuleName,
                    rule -> rule.validate(payment, existingPayments)
                ));
        
        FeeCalculation feeCalculation = FeeCalculation.calculate(payment.getAmount());
        
        return PaymentValidationResult.builder()
                .emailValidation(results.get("EmailValidation"))
                .duplicatePaymentValidation(results.get("DuplicatePayment"))
                .amountThresholdValidation(results.get("AmountThreshold"))
                .overUnderPaymentValidation(results.get("PaymentAmount"))
                .feeCalculation(feeCalculation)
                .validEmail(results.get("EmailValidation").isValid())
                .duplicate(!results.get("DuplicatePayment").isValid())
                .aboveThreshold(!results.get("AmountThreshold").isValid())
                .feePercentage(feeCalculation.getFeePercentage().intValue())
                .feeAmount(feeCalculation.getFeeAmount())
                .finalAmount(feeCalculation.getTotalAmount())
                .paymentStatus(determinePaymentStatus(results))
                .build();
    }
    
    private String determinePaymentStatus(Map<String, ValidationResult> results) {
        boolean hasErrors = results.values().stream().anyMatch(r -> !r.isValid());
        return hasErrors ? "FAILED" : "PASSED";
    }
}