FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy entire project
COPY . .

# Build the entire project (parent POM will be resolved correctly)
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build /app/payment-infra/payment-redis-service/target/payment-redis-service-1.0.0.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]
