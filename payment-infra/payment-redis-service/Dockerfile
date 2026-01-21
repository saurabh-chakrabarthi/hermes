FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy parent pom
COPY pom.xml .

# Copy redis-service module
COPY payment-infra/payment-redis-service/pom.xml payment-infra/payment-redis-service/

# Copy all source code
COPY payment-infra/payment-redis-service/src payment-infra/payment-redis-service/src

# Build only payment-redis-service
RUN mvn -B -pl payment-infra/payment-redis-service -am clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-alpine

WORKDIR /app

RUN apk add --no-cache ca-certificates

COPY --from=builder /app/payment-infra/payment-redis-service/target/payment-redis-service-1.0.0.jar app.jar

EXPOSE 8081

CMD ["java", "-jar", "app.jar"]
