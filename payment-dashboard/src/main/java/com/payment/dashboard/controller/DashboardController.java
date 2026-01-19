package com.payment.dashboard.controller;

import com.payment.dashboard.dto.BookingDTO;
import com.payment.dashboard.service.PaymentApiClient;
import io.micronaut.http.annotation.Controller;
import io.micronaut.http.annotation.Get;
import io.micronaut.views.View;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class DashboardController {

    private final PaymentApiClient paymentApiClient;

    public DashboardController(PaymentApiClient paymentApiClient) {
        this.paymentApiClient = paymentApiClient;
    }

    @Get("/")
    @View("dashboard")
    public Map<String, Object> dashboard() {
        List<BookingDTO> bookings = paymentApiClient.getBookings();
        
        Map<String, Object> model = new HashMap<>();
        model.put("payments", bookings);
        model.put("totalPayments", bookings.size());
        
        return model;
    }

    @Get("/health")
    public Map<String, String> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        return response;
    }
}
