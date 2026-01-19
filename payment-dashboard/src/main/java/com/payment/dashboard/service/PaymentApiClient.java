package com.payment.dashboard.service;

import com.payment.dashboard.dto.BookingDTO;
import io.micronaut.context.annotation.Value;
import io.micronaut.http.client.HttpClient;
import io.micronaut.http.uri.UriBuilder;
import jakarta.inject.Singleton;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Singleton
public class PaymentApiClient {
    private static final Logger log = LoggerFactory.getLogger(PaymentApiClient.class);
    private final HttpClient httpClient;
    private final String redisServiceUrl;

    public PaymentApiClient(HttpClient httpClient, 
                           @Value("${redis-service.base-url}") String redisServiceUrl) {
        this.httpClient = httpClient;
        this.redisServiceUrl = redisServiceUrl;
    }

    /**
     * Get all bookings/transactions from the Redis service
     */
    public List<BookingDTO> getBookings() {
        try {
            log.info("Fetching bookings from Redis service: {}", redisServiceUrl);
            String uri = UriBuilder.of(redisServiceUrl).path("/api/transactions").build().toString();
            BookingDTO[] arr = httpClient.toBlocking().retrieve(uri, BookingDTO[].class);
            return arr == null ? new ArrayList<>() : Arrays.asList(arr);
        } catch (Exception e) {
            log.error("Error fetching bookings from Redis service", e);
            return new ArrayList<>();
        }
    }
}
