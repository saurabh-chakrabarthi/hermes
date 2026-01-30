FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY . .

# Build entire project from root - Maven will handle all modules and dependencies
RUN mvn -B clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17

WORKDIR /app

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/payment-dashboard/target/payment-dashboard-*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
