FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy parent POM first
COPY pom.xml .

# Copy the dashboard module
COPY payment-dashboard/pom.xml ./payment-dashboard/
COPY payment-dashboard/src ./payment-dashboard/src

# Copy redis service module for dependency resolution
COPY payment-infra/payment-redis-service/pom.xml ./payment-infra/payment-redis-service/

# Build the dashboard module
RUN mvn clean package -pl payment-dashboard -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/payment-dashboard/target/payment-dashboard-*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
