package com.payment.redis.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

class TransactionServiceTest {

    @ParameterizedTest
    @CsvSource({
        "1000, 2.0",
        "25000, 2.0",
        "35000, 3.0",
        "45000, 3.0",
        "55000, 5.0",
        "100000, 5.0"
    })
    void testFeeCalculation(String amountStr, String expectedFeeStr) throws Exception {
        BigDecimal amount = new BigDecimal(amountStr);
        BigDecimal expectedFee = new BigDecimal(expectedFeeStr);
        
        // Use reflection to test private method
        var method = TransactionService.class.getDeclaredMethod("calculateFeePercentage", BigDecimal.class);
        method.setAccessible(true);
        
        var service = new TransactionService(null);
        BigDecimal actualFee = (BigDecimal) method.invoke(service, amount);
        
        assertEquals(expectedFee, actualFee);
    }

    @ParameterizedTest
    @CsvSource({
        "1000, 900, UNDERPAYMENT",
        "1000, 1000, EXACT",
        "1000, 1100, OVERPAYMENT"
    })
    void testStatusDetermination(String amountStr, String receivedStr, String expectedStatus) throws Exception {
        BigDecimal amount = new BigDecimal(amountStr);
        BigDecimal received = new BigDecimal(receivedStr);
        
        // Use reflection to test private method
        var method = TransactionService.class.getDeclaredMethod("determineStatus", BigDecimal.class, BigDecimal.class);
        method.setAccessible(true);
        
        var service = new TransactionService(null);
        String actualStatus = (String) method.invoke(service, amount, received);
        
        assertEquals(expectedStatus, actualStatus);
    }
}
