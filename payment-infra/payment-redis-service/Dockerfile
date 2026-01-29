FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY . .

RUN mvn -B clean package -pl payment-infra/payment-redis-service -am -DskipTests

# Runtime stage
FROM eclipse-temurin:17

WORKDIR /app

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/payment-infra/payment-redis-service/target/payment-redis-service-*.jar app.jar

EXPOSE 8081

CMD ["java", "-jar", "app.jar"]
