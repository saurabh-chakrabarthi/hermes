package com.payment.dashboard.service;

import com.payment.dashboard.dto.BookingDTO;
import io.micronaut.context.annotation.Value;
import io.micronaut.http.client.HttpClient;
import io.micronaut.http.uri.UriBuilder;
import jakarta.inject.Singleton;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Singleton
public class PaymentApiClient {
    private final HttpClient httpClient;
    private final String apiBaseUrl;

    public PaymentApiClient(HttpClient httpClient, @Value("${payment-server.base-url}") String apiBaseUrl) {
        this.httpClient = httpClient;
        this.apiBaseUrl = apiBaseUrl;
    }

    public List<BookingDTO> getBookings() {
        try {
            String uri = UriBuilder.of(apiBaseUrl).path("/api/bookings").build().toString();
            BookingDTO[] arr = httpClient.toBlocking().retrieve(uri, BookingDTO[].class);
            return arr == null ? new ArrayList<>() : Arrays.asList(arr);
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }
}
