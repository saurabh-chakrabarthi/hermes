FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy parent POM first
COPY pom.xml .

# Copy the redis service module
COPY payment-infra/payment-redis-service/pom.xml ./payment-infra/payment-redis-service/
COPY payment-infra/payment-redis-service/src ./payment-infra/payment-redis-service/src

# Copy dashboard module for dependency resolution
COPY payment-dashboard/pom.xml ./payment-dashboard/

# Build the redis service module
RUN mvn clean package -pl payment-infra/payment-redis-service -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/payment-infra/payment-redis-service/target/payment-redis-service-*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]
