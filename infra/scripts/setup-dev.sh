#!/bin/bash

# Development Environment Setup Script

echo "Setting up Hermes Payment Portal development environment..."

# Check prerequisites
command -v java >/dev/null 2>&1 || { echo "Java 17+ required"; exit 1; }
command -v ruby >/dev/null 2>&1 || { echo "Ruby 3.0+ required"; exit 1; }

# Setup server
echo "Setting up Ruby server..."
cd server
bundle install
bundle exec rake db:create db:migrate db:seed

# Setup client
echo "Setting up Spring Boot client..."
cd ../client
./mvnw clean install

echo "Development setup complete!"
echo "Start server: cd server && bundle exec rackup"
echo "Start client: cd client && ./mvnw spring-boot:run"