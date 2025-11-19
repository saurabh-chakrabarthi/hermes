#!/bin/bash

# Create OCI Stack via CLI
oci resource-manager stack create \
  --compartment-id "ocid1.tenancy.oc1..aaaaaaaa3h3ywdhnpjp7mq2ysz4h2kjr4knsd2pj6lqm37ru2tgibxudqd2a" \
  --display-name "hermes-payment-portal" \
  --description "Hermes Payment Portal deployment" \
  --config-source-zip-file-path "./hermes-payment-stack.zip"