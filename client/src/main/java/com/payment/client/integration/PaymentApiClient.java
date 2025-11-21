package com.payment.client.integration;

import com.payment.client.dto.BookingResponse;
import com.payment.client.dto.BookingDTO;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.ArrayList;

@Component
public class PaymentApiClient {
    private final RestTemplate restTemplate;
    private final String apiBaseUrl;

    public PaymentApiClient(RestTemplate restTemplate, @Value("${payment-server.base-url}") String apiBaseUrl) {
        this.restTemplate = restTemplate;
        this.apiBaseUrl = apiBaseUrl;
    }

    public BookingResponse getBookings() {
        try {
            // Server returns array directly, so we get it as a List
            ResponseEntity<List<BookingDTO>> responseEntity = restTemplate.exchange(
                apiBaseUrl + "/api/bookings",
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<List<BookingDTO>>() {}
            );
            
            BookingResponse response = new BookingResponse();
            List<BookingDTO> bookings = responseEntity.getBody();
            response.setBookings(bookings != null ? bookings : new ArrayList<>());
            return response;
        } catch (Exception e) {
            // If there's an error, return empty response
            BookingResponse response = new BookingResponse();
            response.setBookings(new ArrayList<>());
            return response;
        }
    }
}
