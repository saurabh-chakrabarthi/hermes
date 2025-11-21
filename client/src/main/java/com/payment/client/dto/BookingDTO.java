package com.payment.client.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.Builder;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class BookingDTO {
    @JsonProperty("reference")
    private String reference;

    @JsonProperty("amount")
    private BigDecimal amount;

    @JsonProperty("amountReceived")
    private BigDecimal amountReceived;

    @JsonProperty("countryFrom")
    private String countryFrom;

    @JsonProperty("senderFullName")
    private String senderFullName;

    @JsonProperty("senderAddress")
    private String senderAddress;

    @JsonProperty("school")
    private String school;

    @JsonProperty("currencyFrom")
    private String currencyFrom;

    @JsonProperty("studentId")
    private String studentId;

    @JsonProperty("email")
    private String email;
}