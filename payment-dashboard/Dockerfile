FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy entire project structure to resolve parent POM
COPY pom.xml .
COPY payment-dashboard ./payment-dashboard
COPY payment-infra ./payment-infra

# Build the dashboard module
RUN mvn clean package -pl payment-dashboard -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/payment-dashboard/target/payment-dashboard-*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
