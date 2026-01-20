# Build stage
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy the parent pom and module poms
COPY pom.xml .
COPY payment-dashboard/pom.xml payment-dashboard/
COPY payment-infra/payment-redis-service/pom.xml payment-infra/payment-redis-service/

# Download dependencies to a cached layer
RUN mvn dependency:go-offline

# Copy the rest of the source code
COPY . .

# Build only the payment-dashboard module
RUN mvn -pl payment-dashboard -am clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-alpine
WORKDIR /app

# Install certificates
RUN apk add --no-cache ca-certificates

# Copy the built application from the build stage
COPY --from=build /app/payment-dashboard/target/payment-dashboard-1.0.0.jar app.jar

# Expose port and run
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
