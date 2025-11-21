package com.payment.client.integration;

import com.payment.client.dto.BookingResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class PaymentApiClient {
    private final RestTemplate restTemplate;
    private final String apiBaseUrl;

    public PaymentApiClient(RestTemplate restTemplate, @Value("${api.base-url}") String apiBaseUrl) {
        this.restTemplate = restTemplate;
        this.apiBaseUrl = apiBaseUrl;
    }

    public BookingResponse getBookings() {
        // Server returns array directly, so we need to handle it
        Object[] bookings = restTemplate.getForObject(apiBaseUrl + "/api/bookings", Object[].class);
        BookingResponse response = new BookingResponse();
        if (bookings != null) {
            response.setBookings(java.util.Arrays.asList(bookings));
        }
        return response;
    }
}
