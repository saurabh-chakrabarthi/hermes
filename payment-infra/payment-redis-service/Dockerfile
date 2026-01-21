FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY . .

RUN mvn -B -pl payment-infra/payment-redis-service -am clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-alpine

WORKDIR /app

RUN apk add --no-cache ca-certificates

COPY --from=builder /app/payment-infra/payment-redis-service/target/payment-redis-service-1.0.0.jar app.jar

EXPOSE 8081

CMD ["java", "-jar", "app.jar"]
