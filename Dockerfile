# Stage 1: Build all Maven projects
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy all pom files first to leverage Docker cache for dependencies
COPY pom.xml .
COPY payment-dashboard/pom.xml payment-dashboard/
COPY payment-infra/payment-redis-service/pom.xml payment-infra/payment-redis-service/

# Copy the rest of the source code
COPY payment-dashboard/src payment-dashboard/src
COPY payment-infra/payment-redis-service/src payment-infra/payment-redis-service/src

# Build all modules. This will download dependencies and compile the code.
# Using -DskipTests to speed up the build
RUN mvn -B -f pom.xml clean package -DskipTests

# Stage 2: Create the image for payment-dashboard
# To build, run: docker build -t payment-dashboard --target payment-dashboard .
FROM eclipse-temurin:17-alpine AS payment-dashboard
WORKDIR /app
COPY --from=builder /app/payment-dashboard/target/*.jar app.jar
CMD ["java", "-jar", "app.jar"]

# Stage 3: Create the image for payment-redis-service
# To build, run: docker build -t payment-redis-service --target payment-redis-service .
FROM eclipse-temurin:17-alpine AS payment-redis-service
WORKDIR /app
COPY --from=builder /app/payment-infra/payment-redis-service/target/*.jar app.jar
CMD ["java", "-jar", "app.jar"]
