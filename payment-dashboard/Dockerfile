FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy parent POM and modules for Maven to resolve dependencies
COPY pom.xml .
COPY payment-dashboard ./payment-dashboard
COPY payment-infra ./payment-infra
COPY dashboard ./dashboard

# Build the payment-dashboard module
RUN mvn clean package -DskipTests -pl payment-dashboard

FROM eclipse-temurin:17
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/payment-dashboard/target/payment-dashboard-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
