# Build stage
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy entire project structure (must be run from repository root)
COPY . .

# Build all modules
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-alpine
WORKDIR /app

# Install certificates
RUN apk add --no-cache ca-certificates

# Copy the built payment-dashboard application
COPY --from=build /app/payment-dashboard/target/payment-dashboard-1.0.0.jar app.jar

# Expose port and run
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
