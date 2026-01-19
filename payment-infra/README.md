# Hermes Payment Remittance Portal - Payment Infra

This directory contains infrastructure-related services for the Hermes Payment Remittance Portal.

## Building Docker Images

To build the Docker images for the services in this directory, you must run the `docker build` command from the **root directory** of the project.

### Building the Payment Redis Service

To build the Docker image for the `payment-redis-service`, run the following command from the project root:

```sh
docker build -f ./payment-infra/payment-redis-service/Dockerfile .
```

This will build the Docker image using the correct build context, which includes all the necessary modules from the project.
