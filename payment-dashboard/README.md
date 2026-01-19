# Hermes Payment Remittance Portal - Payment Dashboard

This directory contains the payment-dashboard service for the Hermes Payment Remittance Portal.

## Building Docker Image

To build the Docker image for the `payment-dashboard` service, you must run the `docker build` command from the **root directory** of the project.

### Building the Payment Dashboard Service

To build the Docker image for the `payment-dashboard` service, run the following command from the project root:

```sh
docker build -f ./payment-dashboard/Dockerfile .
```

This will build the Docker image using the correct build context, which includes all the necessary modules from the project.
