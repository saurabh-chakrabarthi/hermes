package com.payment.client.service;

import com.payment.client.domain.FeeCalculation;
import com.payment.client.domain.Payment;
import com.payment.client.domain.PaymentValidationResult;
import com.payment.client.domain.ValidationResult;
import com.payment.client.dto.BookingDTO;
import com.payment.client.dto.BookingResponse;
import com.payment.client.integration.PaymentApiClient;
import com.payment.client.integration.PaymentMapper;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PaymentService {
    private final PaymentApiClient paymentApiClient;
    private final PaymentValidationService paymentValidationService;
    private final EmailValidationService emailValidationService;
    private final PaymentMapper paymentMapper;

    public PaymentService(PaymentApiClient paymentApiClient,
                         PaymentValidationService paymentValidationService,
                         EmailValidationService emailValidationService,
                         PaymentMapper paymentMapper) {
        this.paymentApiClient = paymentApiClient;
        this.paymentValidationService = paymentValidationService;
        this.emailValidationService = emailValidationService;
        this.paymentMapper = paymentMapper;
    }

    public List<Payment> getAllPayments() {
        BookingResponse response = paymentApiClient.getBookings();
        return response.getBookings().stream()
                .map(paymentMapper::toPayment)
                .collect(Collectors.toList());
    }

    public PaymentValidationResult validatePayment(BookingDTO bookingDTO) {
        List<Payment> existingPayments = getAllPayments();
        ValidationResult emailValidation = emailValidationService.validateEmail(bookingDTO.getEmail());
        ValidationResult duplicatePaymentValidation = paymentValidationService.validateDuplicatePayment(bookingDTO, existingPayments);
        ValidationResult amountThresholdValidation = paymentValidationService.validateAmountThreshold(bookingDTO.getAmount());
        ValidationResult overUnderPaymentValidation = paymentValidationService.validateOverUnderPayment(bookingDTO.getAmount(), bookingDTO.getAmountReceived());

        FeeCalculation feeCalculation = FeeCalculation.calculate(bookingDTO.getAmount());
        
        // Determine payment status
        String paymentStatus = "UNKNOWN";
        if (bookingDTO.getAmount() != null && bookingDTO.getAmountReceived() != null) {
            if (bookingDTO.getAmount().equals(bookingDTO.getAmountReceived())) {
                paymentStatus = "EXACT";
            } else if (bookingDTO.getAmountReceived().compareTo(bookingDTO.getAmount()) > 0) {
                paymentStatus = "OVERPAYMENT";
            } else {
                paymentStatus = "UNDERPAYMENT";
            }
        }

        return PaymentValidationResult.builder()
                .emailValidation(emailValidation)
                .duplicatePaymentValidation(duplicatePaymentValidation)
                .amountThresholdValidation(amountThresholdValidation)
                .overUnderPaymentValidation(overUnderPaymentValidation)
                .feeCalculation(feeCalculation)
                .paymentStatus(paymentStatus)
                .validEmail(emailValidation.isValid())
                .duplicate(!duplicatePaymentValidation.isValid())
                .aboveThreshold(!amountThresholdValidation.isValid())
                .feePercentage(feeCalculation.getFeePercentage().intValue())
                .feeAmount(feeCalculation.getFeeAmount())
                .finalAmount(feeCalculation.getTotalAmount())
                .build();
    }
}
