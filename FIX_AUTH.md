## Fix OCI Authentication Error

The 401-NotAuthenticated error means OCI credentials are incorrect or incomplete.

### Missing Secret
You need to add **OCI_COMPARTMENT_ID** to GitHub organization secrets.

### Get Compartment ID

```bash
# Option 1: Use root compartment (= tenancy OCID)
echo "ocid1.tenancy.oc1..aaaaaaaa3h3ywdhnpjp7mq2ysz4h2kjr4knsd2pj6lqm37ru2tgibxudqd2a"

# Option 2: List all compartments (if auth works locally)
oci iam compartment list --all | jq -r '.data[] | "\(.name): \(.id)"'
```

### Verify OCI CLI Works Locally

```bash
# Test authentication
oci iam region list

# If this fails, check:
cat ~/.oci/config
cat ~/.oci/oci_api_key.pem | head -1
cat ~/.oci/oci_api_key.pem | tail -1

# Add security label if missing
echo "OCI_API_KEY" >> ~/.oci/oci_api_key.pem
```

### Add to GitHub Secrets

Go to: `https://github.com/organizations/<YOUR_ORG>/settings/secrets/actions`

Add:
- Name: `OCI_COMPARTMENT_ID`
- Value: `ocid1.tenancy.oc1..aaaaaaaa3h3ywdhnpjp7mq2ysz4h2kjr4knsd2pj6lqm37ru2tgibxudqd2a`

### Verify All Secrets Match

Run locally to compare with GitHub secrets:
```bash
cat ~/.oci/config

# Should match:
# user -> OCI_USER_OCID
# fingerprint -> OCI_FINGERPRINT  
# tenancy -> OCI_TENANCY_OCID
# region -> OCI_REGION
# key_file content -> OCI_PRIVATE_KEY
```

The private key in GitHub must be the **exact content** of the PEM file, including:
- `-----BEGIN RSA PRIVATE KEY-----`
- All lines in between
- `-----END RSA PRIVATE KEY-----`
