FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY . .

# Install parent POM to local Maven repository (-f = explicit root pom.xml, -N = non-recursive, only parent)
RUN mvn -B -f pom.xml install -N -DskipTests

# Build only the payment-dashboard module
RUN mvn -B -f payment-dashboard/pom.xml clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17

WORKDIR /app

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/payment-dashboard/target/payment-dashboard-*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
