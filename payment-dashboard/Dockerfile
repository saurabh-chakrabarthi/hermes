FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

COPY . .

# Install parent POM first so it's available locally
RUN mvn install -N -DskipTests

# Build the dashboard module
RUN mvn clean package -pl payment-dashboard -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/payment-dashboard/target/payment-dashboard-*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
