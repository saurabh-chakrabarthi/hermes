FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy entire project
COPY . .

# Install parent POM first so it's available locally
RUN mvn install -N -DskipTests

# Build the redis service module
RUN mvn clean package -pl payment-infra/payment-redis-service -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/payment-infra/payment-redis-service/target/payment-redis-service-*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/payment-infra/payment-redis-service/target/payment-redis-service-*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]
