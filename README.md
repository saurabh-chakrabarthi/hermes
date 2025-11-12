# Booking portal

The "Booking portal" is an application with the purpose of
creating payment bookings. It consists on a payment form with the following structure:

<img width="1090" height="640" alt="image" src="https://github.com/user-attachments/assets/e3ad504a-1032-46c4-9d12-a682c1593409" />


When the form is submitted, the application creates a payment record with the provided information.

This application also has an API consisting of 2 endpoints that are detailed on the [Readme](server/README.md).

There's a second application, inside the ``client`` directory, that communicates with the "booking portal" application in order to accomplish the following:

When a payment is booked, this payment has to go through a "quality check", the purpose of this quality check is to assure that the payment meets some defined "quality" criteria, this criteria consists on the following rules:

* **InvalidEmail**: The payment has an invalid email.
* **DuplicatedPayment**: The user that booked the payment has already a payment in the system.
* **AmountThreshold**: The amount of the payment is bigger than 1.000.000$

The application shows if any of this "quality check" criteria are not met.

Besides "quality check", it also checks for "over" and "under" payments [1]:

* An **over-payment** happens when the user pays more than the tuition amount we introduced in the booking portal.
* An **under-payment** is just the opposite.

As a final step, we add to the amount some fees depending on the magnitude of the amount, this fees are:

* if the amount < 1000 USD: 5% fees
* if the amount > 1000 USD AND < 10000 USD: 3% fees
* if the amount > 10000 USD: 2% fees

Note : Closing this pull request as I have opened a new PR : https://github.com/flywire-homework/dev_saurabh_chakrabarthi/pull/2 which contains all the changes

## Overview

This code implements a Spring Boot client application that integrates with the existing booking portal to provide comprehensive payment quality checks, validation, and fee calculations as specified in the requirements.

## Implementation Approach

### Architecture Decision: Spring Boot Architecture

**Why Spring Boot?**
- **Rapid Development**: Built-in dependency injection, auto-configuration, and embedded server
- **Production Ready**: Actuator for health checks, comprehensive testing support
- **Integration Friendly**: Excellent REST client capabilities with WebClient
- **Maintainable**: Clear separation of concerns with service layers

**Clean Architecture Pattern:**
```
├── controller/     # Web layer (REST endpoints, UI)
├── service/        # Business logic layer
├── domain/         # Core business entities
├── dto/           # Data transfer objects
├── integration/   # External API integration
└── config/        # Configuration classes
```

### Key Technical Decisions

1. **WebClient over RestTemplate**: Non-blocking, reactive HTTP client for better performance
2. **Lombok**: Reduces boilerplate code while maintaining readability
3. **Thymeleaf**: Server-side templating for the dashboard UI
4. **Builder Pattern**: Immutable object creation for better code quality
5. **Comprehensive Testing**: Unit tests, integration tests, and service layer tests

## Features Implemented

### Quality Check Rules
- **Invalid Email**: Email validation using regex pattern
- **Duplicate Payment**: Detects same email with different payment references
- **Amount Threshold**: Flags payments exceeding $1,000,000
- **Over/Under Payment**: Compares tuition amount vs amount received for over vs under payment

### Fee Calculation System
```java
// Tiered fee structure implementation
< $1,000:     5% fee
$1,000-$10,000: 3% fee  
> $10,000:    2% fee
```

### Dashboard Interface
- Real-time payment status visualization
- Quality check results with color-coded badges
- Fee calculations and final amounts
- Refresh button and auto refresh logic to see new transactions

<img width="1324" height="620" alt="image" src="https://github.com/user-attachments/assets/75fe112d-4a68-49f4-9373-8bfb460513c1" />


### Docker Integration
- Multi-stage Docker build for optimized image size
- Docker Compose orchestration with booking portal

## 📁 Project Structure

```
client/
├── src/main/java/com/payment/client/
│   ├── PaymentClientApplication.java      # Spring Boot entry point
│   ├── controller/
│   │   └── DashboardController.java       # Web UI controller
│   ├── service/
│   │   ├── PaymentService.java           # Core business logic
│   │   ├── PaymentValidationService.java # Validation rules
│   │   ├── EmailValidationService.java   # Email validation
│   │   └── DashboardService.java         # Dashboard data
│   ├── domain/
│   │   ├── Payment.java                  # Payment entity
│   │   ├── PaymentValidationResult.java  # Validation results
│   │   ├── FeeCalculation.java          # Fee calculation logic
│   │   └── ValidationResult.java         # Individual validation
│   ├── dto/
│   │   ├── BookingDTO.java              # API data transfer
│   │   ├── DashboardDTO.java            # Dashboard data
│   │   └── PaymentDTO.java              # Payment display data
│   ├── integration/
│   │   ├── PaymentApiClient.java        # Booking portal client
│   │   └── PaymentMapper.java           # Entity mapping
│   └── config/
│       ├── RestClientConfig.java        # WebClient configuration
│       └── RulesConfig.java            # Validation rules config
├── src/test/java/                       # Comprehensive test suite
├── src/main/resources/
│   ├── templates/dashboard.html         # Thymeleaf template
│   ├── static/css/dashboard.css         # Custom styles
│   └── application.yml                  # Configuration
├── docker-compose.yml                   # Multi-service orchestration
├── Dockerfile                          # Multi-stage build
└── pom.xml                            # Maven dependencies
```

## 🔧 Configuration & Deployment

### Environment Configuration
```yaml
# application.yml
api:
  base-url: ${API_BASE_URL:http://localhost:9292}
  
server:
  port: 8080
  
management:
  endpoints:
    web:
      exposure:
        include: health,info
```

### Docker Deployment
```bash
# Start both client and server
docker-compose up --build

# Access points:
# - Client Dashboard: http://localhost:8080
# - Booking Portal: http://localhost:9292
```

## Testing Strategy

### Test Coverage
- **Unit Tests**: Service layer business logic validation
- **Integration Tests**: API client and end-to-end workflows  
- **Domain Tests**: Fee calculation and validation rules
- **Mock Testing**: External API dependencies

### Key Test Scenarios
```java
@Test
void validatePayment_HappyPath_AllValidationsPassed()
void validatePayment_InvalidEmail_ShouldFailEmailValidation()  
void validatePayment_AmountAboveThreshold_ShouldFailThresholdValidation()
void calculateFees_DifferentAmountTiers_CorrectFeePercentages()
```

## User Experience

### Dashboard Features
- **Visual Indicators**: Color-coded status badges (success/warning/danger)
- **Comprehensive View**: All validation results, fees, and final amounts

### Quality Check Display
```html
<!-- Example output -->
PASSED (all validations successful)
Invalid Email + Duplicate Payment  
Above Threshold
5% fee ($25.00) → Final: $525.00
```

## Code Quality & Best Practices

### Design Patterns Used
- **Builder Pattern**: Immutable object creation
- **Service Layer Pattern**: Business logic separation
- **Repository Pattern**: Data access abstraction
- **DTO Pattern**: API boundary objects

### Spring Boot Best Practices
- Configuration properties with validation
- Proper exception handling
- Dependency injection with constructor injection
- Profile-based configuration

## API Integration

### Booking Portal Integration
```java
@Component
public class PaymentApiClient {
    public BookingResponse getBookings() {
        return webClient.get()
            .uri("/api/bookings")
            .retrieve()
            .bodyToMono(BookingResponse.class)
            .block();
    }
}
```

## Security Considerations

### Input Validation
- Email format validation with regex
- Amount validation (positive numbers only)

### Configuration Security
- No hardcoded credentials
- Environment-based configuration

## Future Enhancements

### Potential Improvements
- **Real-time Notifications**: WebSocket integration for live updates
- **Advanced Analytics**: Payment trends and quality metrics
- **Rule Engine**: Dynamic validation rule configuration
- **Audit Trail**: Complete payment validation history
- **API Documentation**: OpenAPI/Swagger integration
- **Performance Monitoring**: APM integration (New Relic, DataDog)


## Summary

This implementation provides a robust, production-ready solution that:

**Meets All Requirements**: Complete quality check implementation with fee calculations  
**Production Ready**: Comprehensive testing, Docker deployment, health checks  
**Maintainable**: Clean architecture, proper separation of concerns  
**Scalable**: Stateless design, configurable components  
**User Friendly**: Intuitive dashboard with clear visual indicators  


<img width="1324" height="620" alt="image" src="https://github.com/user-attachments/assets/3eca4e23-9425-4ca1-8e60-5a9d2eb24d49" />


