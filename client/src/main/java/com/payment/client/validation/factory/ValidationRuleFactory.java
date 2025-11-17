package com.payment.client.validation.factory;

import com.payment.client.validation.ValidationRule;
import com.payment.client.validation.rules.*;
import org.springframework.stereotype.Component;
import java.util.Map;
import java.util.HashMap;

/**
 * Factory pattern for creating validation rules
 */
@Component
public class ValidationRuleFactory {
    private final Map<String, ValidationRule> ruleRegistry = new HashMap<>();
    
    public ValidationRuleFactory(EmailValidationRule emailRule,
                               DuplicatePaymentRule duplicateRule,
                               AmountThresholdRule thresholdRule,
                               PaymentAmountRule amountRule) {
        ruleRegistry.put("EMAIL", emailRule);
        ruleRegistry.put("DUPLICATE", duplicateRule);
        ruleRegistry.put("THRESHOLD", thresholdRule);
        ruleRegistry.put("AMOUNT", amountRule);
    }
    
    public ValidationRule createRule(String ruleType) {
        ValidationRule rule = ruleRegistry.get(ruleType.toUpperCase());
        if (rule == null) {
            throw new IllegalArgumentException("Unknown validation rule type: " + ruleType);
        }
        return rule;
    }
}