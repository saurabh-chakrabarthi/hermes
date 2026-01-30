FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY . .

# Install parent POM to local Maven repository (-f = explicit root pom.xml, -N = non-recursive, only parent)
RUN mvn -B -f pom.xml install -N -DskipTests

# Build only the payment-redis-service module
RUN mvn -B -f payment-infra/payment-redis-service/pom.xml clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17

WORKDIR /app

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/payment-infra/payment-redis-service/target/payment-redis-service-*.jar app.jar

EXPOSE 8081

CMD ["java", "-jar", "app.jar"]
