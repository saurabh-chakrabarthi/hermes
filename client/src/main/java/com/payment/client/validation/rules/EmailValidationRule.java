package com.payment.client.validation.rules;

import com.payment.client.domain.Payment;
import com.payment.client.domain.ValidationResult;
import com.payment.client.validation.AbstractValidationRule;
import org.springframework.stereotype.Component;
import java.util.List;
import java.util.regex.Pattern;

@Component
public class EmailValidationRule extends AbstractValidationRule {
    private static final Pattern EMAIL_PATTERN = 
        Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    
    @Override
    protected ValidationResult performValidation(Payment payment, List<Payment> existingPayments) {
        String email = payment.getEmail();
        if (email == null || email.trim().isEmpty()) {
            return createInvalidResult("Email cannot be empty", ValidationResult.ValidationErrorType.INVALID_EMAIL);
        }
        
        boolean isValid = EMAIL_PATTERN.matcher(email).matches();
        return isValid ? 
            createValidResult("Valid email") : 
            createInvalidResult("Invalid email format", ValidationResult.ValidationErrorType.INVALID_EMAIL);
    }
    
    @Override
    public String getRuleName() {
        return "EmailValidation";
    }
}