FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy entire project
COPY . .

# Build the entire project (parent POM will be resolved correctly)
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/payment-dashboard/target/payment-dashboard-*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
