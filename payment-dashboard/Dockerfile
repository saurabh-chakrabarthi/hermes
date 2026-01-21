FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY . .

RUN mvn -B -pl payment-dashboard -am clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-alpine

WORKDIR /app

RUN apk add --no-cache ca-certificates

COPY --from=builder /app/payment-dashboard/target/payment-dashboard-1.0.0.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
