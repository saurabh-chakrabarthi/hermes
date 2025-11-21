# Hermes Payment Portal

The **Hermes Payment Portal** is an application designed to facilitate payment bookings. It features a user-friendly payment form and a comprehensive client dashboard.

### Screens

<table>
  <tr>
    <td><strong>Landing Page</strong></td>
    <td><strong>Payment Confirmation</strong></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/5b6cfde5-2ef5-4aff-a436-d2dcb2baea5d" width="350"/></td>
    <td><img src="https://github.com/user-attachments/assets/0eb24d16-4eba-40e4-8845-a5dad75293d6" width="350"/></td>
  </tr>

  <tr>
    <td colspan="2" align="center"><strong>Client Dashboard</strong></td>
  </tr>
  <tr>
    <td colspan="2" align="center">
      <img src="https://github.com/user-attachments/assets/b898dac3-268c-48c1-9e01-053a59aa526b" width="700"/>
    </td>
  </tr>
</table>

When a form is submitted, the application creates a payment record with the provided information. The portal also exposes an API with two endpoints detailed in the [server README](server/README.md).

Inside the `client` directory, a second application interacts with the **Hermes Payment Portal** to enforce **quality checks** and additional rules:

### Quality Check Rules
- **InvalidEmail**: Flags payments with invalid email addresses.
- **DuplicatedPayment**: Detects if a user already has an existing payment.
- **AmountThreshold**: Flags payments exceeding $1,000,000.

The client also evaluates **over-payments** and **under-payments** based on the tuition amount defined in the portal:

- **Over-payment**: Payment exceeds tuition amount.
- **Under-payment**: Payment is below tuition amount.

### Fee Structure
Applied based on the payment amount:

- `< $1,000 USD`: 5% fee  
- `$1,000 - $10,000 USD`: 3% fee  
- `> $10,000 USD`: 2% fee  

---

## Overview

The client application is a **Spring Boot** service integrating with the **Hermes Payment Portal** to implement:

- Payment quality checks  
- Validation rules  
- Fee calculations  
- Dashboard visualization  

### Architecture

**Why Spring Boot?**

- **Rapid Development**: Built-in DI, auto-configuration, embedded server  
- **Production Ready**: Health checks with Actuator, robust testing support  
- **Integration Friendly**: REST clients via WebClient  
- **Maintainable**: Layered architecture  

**Clean Architecture:**

```
├── controller/ # REST endpoints and UI controllers
├── service/ # Business logic
├── domain/ # Core entities
├── dto/ # Data Transfer Objects
├── integration/ # External API integrations
└── config/ # Configuration classes
```

**Key Technical Decisions:**

1. **WebClient over RestTemplate** for non-blocking requests  
2. **Lombok** to reduce boilerplate  
3. **Thymeleaf** for dashboard templating  
4. **Builder Pattern** for immutable objects  
5. Comprehensive **unit & integration testing**  

---

## Features

### Quality Checks
- Email validation using regex  
- Duplicate payment detection  
- Amount threshold check  
- Over/under-payment comparison  

### Fee Calculation
```java
// Tiered fee implementation
< $1,000:     5% fee
$1,000-$10,000: 3% fee
> $10,000:    2% fee
```

### Dashboard Interface
- Real-time payment status
- Color-coded badges for validation results
- Fee calculation and final amount display
- Manual and auto-refresh

### Docker Integration
- Multi-stage Docker build for optimized image size
- Docker Compose orchestration with hermes portal

## 📁 Project Structure

```
client/
├── src/main/java/com/payment/client/
│   ├── PaymentClientApplication.java
│   ├── controller/
│   │   └── DashboardController.java
│   ├── service/
│   │   ├── PaymentService.java
│   │   ├── PaymentValidationService.java
│   │   ├── EmailValidationService.java
│   │   └── DashboardService.java
│   ├── domain/
│   │   ├── Payment.java
│   │   ├── PaymentValidationResult.java
│   │   ├── FeeCalculation.java
│   │   └── ValidationResult.java
│   ├── dto/
│   │   ├── BookingDTO.java
│   │   ├── DashboardDTO.java
│   │   └── PaymentDTO.java
│   ├── integration/
│   │   ├── PaymentApiClient.java
│   │   └── PaymentMapper.java
│   └── config/
│       ├── RestClientConfig.java
│       └── RulesConfig.java
├── src/test/java/
├── src/main/resources/
│   ├── templates/dashboard.html
│   ├── static/css/dashboard.css
│   └── application.yml
├── docker-compose.yml
├── Dockerfile
└── pom.xml
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
# - Hermes Portal: http://localhost:9292
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

### Hermes Portal Integration
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


