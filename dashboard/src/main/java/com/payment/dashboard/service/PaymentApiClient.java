package com.payment.dashboard.service;

import com.payment.dashboard.dto.BookingDTO;
import io.micronaut.http.client.HttpClient;
import io.micronaut.http.client.annotation.Client;
import io.micronaut.http.uri.UriBuilder;
import jakarta.inject.Singleton;

import java.util.ArrayList;
import java.util.List;

@Singleton
public class PaymentApiClient {
    private final HttpClient httpClient;
    private final String apiBaseUrl;

    public PaymentApiClient(@Client("${payment-server.base-url}") HttpClient httpClient,
                           io.micronaut.context.annotation.Value("${payment-server.base-url}") String apiBaseUrl) {
        this.httpClient = httpClient;
        this.apiBaseUrl = apiBaseUrl;
    }

    public List<BookingDTO> getBookings() {
        try {
            return httpClient.toBlocking()
                    .retrieve(UriBuilder.of(apiBaseUrl).path("/api/bookings").build(),
                            io.micronaut.core.type.Argument.listOf(BookingDTO.class));
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }
}
