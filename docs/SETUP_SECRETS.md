# 🔐 GitHub Secrets Setup Guide

## Step 1: Run the Secret Generator Script

On your local machine or OCI VM where OCI CLI is configured:

```bash
./scripts/get-oci-secrets.sh
```

This will output all the values you need for GitHub secrets.

## Step 2: Add Secrets to GitHub

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Add each secret with the exact name and value from the script output

## Required Secrets

| Secret Name | Description |
|-------------|-------------|
| `OCI_USER_OCID` | Your OCI user identifier |
| `OCI_TENANCY_OCID` | Your OCI tenancy identifier |
| `OCI_REGION` | OCI region (e.g., us-ashburn-1) |
| `OCI_FINGERPRINT` | API key fingerprint |
| `OCI_PRIVATE_KEY` | Private key content (including headers) |
| `OCI_COMPARTMENT_ID` | Compartment where resources will be created |
| `SSH_PUBLIC_KEY` | SSH public key for VM access |

## Prerequisites

- OCI CLI installed and configured (`oci setup config`)
- SSH key pair generated (`ssh-keygen -t rsa -b 4096`)
- OCI API key created in OCI Console

## Troubleshooting

**OCI CLI not configured?**
```bash
oci setup config
```

**No SSH key?**
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

**Missing API key?**
1. OCI Console → Identity & Security → Users → Your User
2. API Keys → Add API Key
3. Upload the public key from `~/.oci/oci_api_key_public.pem`

## Security Notes

- Never commit these values to your repository
- Keep your private key secure
- Rotate keys regularly
- Use least privilege access