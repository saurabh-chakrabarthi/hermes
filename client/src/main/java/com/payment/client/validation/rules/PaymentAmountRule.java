package com.payment.client.validation.rules;

import com.payment.client.domain.Payment;
import com.payment.client.domain.ValidationResult;
import com.payment.client.validation.AbstractValidationRule;
import org.springframework.stereotype.Component;
import java.util.List;

@Component
public class PaymentAmountRule extends AbstractValidationRule {
    
    @Override
    protected ValidationResult performValidation(Payment payment, List<Payment> existingPayments) {
        if (payment.getAmount().equals(payment.getAmountReceived())) {
            return createValidResult("Payment amount matches");
        }
        
        boolean isOverPayment = payment.getAmountReceived().compareTo(payment.getAmount()) > 0;
        return isOverPayment ?
            createInvalidResult("Over payment detected", ValidationResult.ValidationErrorType.OVER_PAYMENT) :
            createInvalidResult("Under payment detected", ValidationResult.ValidationErrorType.UNDER_PAYMENT);
    }
    
    @Override
    public String getRuleName() {
        return "PaymentAmount";
    }
}