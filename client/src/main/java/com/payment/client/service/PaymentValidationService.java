package com.payment.client.service;

import com.payment.client.domain.Payment;
import com.payment.client.domain.ValidationResult;
import com.payment.client.dto.BookingDTO;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class PaymentValidationService {
    
    public ValidationResult validateDuplicatePayment(BookingDTO payment, List<Payment> existingPayments) {
        List<BookingDTO> existingBookingDTOs = existingPayments.stream()
                .map(this::convertToBookingDTO)
                .collect(Collectors.toList());

        boolean isDuplicate = existingBookingDTOs.stream()
                .anyMatch(p -> p.getEmail() != null && payment.getEmail() != null &&
                        p.getEmail().equalsIgnoreCase(payment.getEmail()) &&
                        p.getReference() != null && payment.getReference() != null &&
                        !p.getReference().equals(payment.getReference()));
        
        return ValidationResult.builder()
                .valid(!isDuplicate)
                .errorType(isDuplicate ? ValidationResult.ValidationErrorType.DUPLICATED_PAYMENT :
                         ValidationResult.ValidationErrorType.NONE)
                .message(isDuplicate ? "Duplicate payment found for this email" : "No duplicate payment")
                .build();
    }

    private BookingDTO convertToBookingDTO(Payment payment) {
        return BookingDTO.builder()
                .reference(payment.getReference())
                .amount(payment.getAmount())
                .amountReceived(payment.getAmountReceived())
                .countryFrom(payment.getCountryFrom())
                .senderFullName(payment.getSenderFullName())
                .senderAddress(payment.getSenderAddress())
                .school(payment.getSchool())
                .currencyFrom(payment.getCurrencyFrom())
                .studentId(payment.getStudentId())
                .email(payment.getEmail())
                .build();
    }
    
    public ValidationResult validateAmountThreshold(BigDecimal amount) {
        boolean exceededThreshold = amount.compareTo(BigDecimal.valueOf(1_000_000)) > 0;
        
        return ValidationResult.builder()
                .valid(!exceededThreshold)
                .errorType(exceededThreshold ? ValidationResult.ValidationErrorType.AMOUNT_THRESHOLD_EXCEEDED :
                         ValidationResult.ValidationErrorType.NONE)
                .message(exceededThreshold ? "Amount exceeds maximum threshold of ,000,000" : "Amount within threshold")
                .build();
    }
    
    public ValidationResult validateOverUnderPayment(BigDecimal amount, BigDecimal amountReceived) {
        if (amount != null && amountReceived != null && amount.equals(amountReceived)) {
            return ValidationResult.builder()
                    .valid(true)
                    .errorType(ValidationResult.ValidationErrorType.NONE)
                    .message("Payment amount matches")
                    .build();
        }
        
        if (amount == null || amountReceived == null) {
            return ValidationResult.builder()
                    .valid(false)
                    .errorType(ValidationResult.ValidationErrorType.NONE)
                    .message("Invalid payment amounts")
                    .build();
        }
        
        boolean isOverPayment = amountReceived.compareTo(amount) > 0;
        return ValidationResult.builder()
                .valid(false)
                .errorType(isOverPayment ? ValidationResult.ValidationErrorType.OVER_PAYMENT :
                         ValidationResult.ValidationErrorType.UNDER_PAYMENT)
                .message(isOverPayment ? "Over payment detected" : "Under payment detected")
                .build();
    }
}