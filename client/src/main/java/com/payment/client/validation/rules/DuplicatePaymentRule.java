package com.payment.client.validation.rules;

import com.payment.client.domain.Payment;
import com.payment.client.domain.ValidationResult;
import com.payment.client.validation.AbstractValidationRule;
import org.springframework.stereotype.Component;
import java.util.List;

@Component
public class DuplicatePaymentRule extends AbstractValidationRule {
    
    @Override
    protected ValidationResult performValidation(Payment payment, List<Payment> existingPayments) {
        if (existingPayments == null || existingPayments.isEmpty()) {
            return createValidResult("No existing payments to check");
        }
        
        boolean isDuplicate = existingPayments.stream()
                .anyMatch(p -> p.getEmail() != null && 
                        p.getEmail().equalsIgnoreCase(payment.getEmail()) &&
                        !p.getReference().equals(payment.getReference()));
        
        return isDuplicate ? 
            createInvalidResult("Duplicate payment found for this email", ValidationResult.ValidationErrorType.DUPLICATED_PAYMENT) :
            createValidResult("No duplicate payment");
    }
    
    @Override
    public String getRuleName() {
        return "DuplicatePayment";
    }
}