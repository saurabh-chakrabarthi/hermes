FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy parent pom
COPY pom.xml .

# Copy payment-dashboard module
COPY payment-dashboard/pom.xml payment-dashboard/

# Copy all source code
COPY payment-dashboard/src payment-dashboard/src

# Build only payment-dashboard
RUN mvn -B -pl payment-dashboard -am clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-alpine

WORKDIR /app

RUN apk add --no-cache ca-certificates

COPY --from=builder /app/payment-dashboard/target/payment-dashboard-1.0.0.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
