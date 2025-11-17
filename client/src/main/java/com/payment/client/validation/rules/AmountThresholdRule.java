package com.payment.client.validation.rules;

import com.payment.client.domain.Payment;
import com.payment.client.domain.ValidationResult;
import com.payment.client.validation.AbstractValidationRule;
import org.springframework.stereotype.Component;
import java.math.BigDecimal;
import java.util.List;

@Component
public class AmountThresholdRule extends AbstractValidationRule {
    private static final BigDecimal THRESHOLD = BigDecimal.valueOf(1_000_000);
    
    @Override
    protected ValidationResult performValidation(Payment payment, List<Payment> existingPayments) {
        boolean exceededThreshold = payment.getAmount().compareTo(THRESHOLD) > 0;
        
        return exceededThreshold ?
            createInvalidResult("Amount exceeds maximum threshold of $1,000,000", ValidationResult.ValidationErrorType.AMOUNT_THRESHOLD_EXCEEDED) :
            createValidResult("Amount within threshold");
    }
    
    @Override
    public String getRuleName() {
        return "AmountThreshold";
    }
}