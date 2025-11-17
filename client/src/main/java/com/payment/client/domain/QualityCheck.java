package com.payment.client.domain;

import lombok.Builder;
import lombok.Data;

/**
 * Represents a quality check result for a payment.
 * This class follows the Builder pattern and encapsulates validation results.
 */
@Data
@Builder
public class QualityCheck {


    private boolean validEmail;
    private boolean duplicate;
    private boolean aboveThreshold;
    private PaymentStatus paymentStatus;
    private FeeCalculation feeCalculation;
    private String message;

    /**
     * Checks if any quality rules are violated
     * @return true if all quality checks pass, false otherwise
     */
    public boolean isValid() {
        return validEmail && !duplicate && !aboveThreshold &&
               paymentStatus == PaymentStatus.EXACT;
    }

    /**
     * Factory method to create QualityCheck from PaymentValidationResult
     * @param validationResult The validation result from ValidationEngine
     * @return QualityCheck instance
     */
    public static QualityCheck fromValidationResult(PaymentValidationResult validationResult) {
        StringBuilder message = new StringBuilder();
        
        if (!validationResult.isValidEmail()) message.append("Invalid email. ");
        if (validationResult.isDuplicate()) message.append("Duplicate payment found. ");
        if (validationResult.isAboveThreshold()) message.append("Amount exceeds threshold. ");
        
        PaymentStatus status = determinePaymentStatus(validationResult);
        if (status != PaymentStatus.EXACT) {
            message.append(status.getDescription()).append(". ");
        }

        return QualityCheck.builder()
                .validEmail(validationResult.isValidEmail())
                .duplicate(validationResult.isDuplicate())
                .aboveThreshold(validationResult.isAboveThreshold())
                .paymentStatus(status)
                .feeCalculation(validationResult.getFeeCalculation())
                .message(message.length() > 0 ? message.toString().trim() : "All checks passed")
                .build();
    }
    
    private static PaymentStatus determinePaymentStatus(PaymentValidationResult result) {
        if (result.getOverUnderPaymentValidation() == null || result.getOverUnderPaymentValidation().isValid()) {
            return PaymentStatus.EXACT;
        }
        
        ValidationResult.ValidationErrorType errorType = result.getOverUnderPaymentValidation().getErrorType();
        return errorType == ValidationResult.ValidationErrorType.OVER_PAYMENT ? 
            PaymentStatus.OVERPAYMENT : PaymentStatus.UNDERPAYMENT;
    }
}

