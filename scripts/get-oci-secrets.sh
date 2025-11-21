#!/bin/bash

echo "🔐 OCI GitHub Secrets Generator"
echo "================================"
echo ""

# Check if OCI CLI is installed
if ! command -v oci &> /dev/null; then
    echo "❌ OCI CLI not found. Please install it first:"
    echo "   bash -c \"\$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)\""
    exit 1
fi

# Check if OCI CLI is configured
if [ ! -f ~/.oci/config ]; then
    echo "❌ OCI CLI not configured. Please run: oci setup config"
    exit 1
fi

echo "✅ OCI CLI found and configured"
echo ""

# Get current OCI configuration
OCI_CONFIG_FILE=~/.oci/config
DEFAULT_PROFILE="DEFAULT"

echo "📋 GitHub Secrets Configuration:"
echo "================================"

# 1. OCI_USER_OCID
USER_OCID=$(oci iam user list --query 'data[0]."id"' --raw-output 2>/dev/null || grep "user=" $OCI_CONFIG_FILE | cut -d'=' -f2)
echo "OCI_USER_OCID=$USER_OCID"

# 2. OCI_TENANCY_OCID  
TENANCY_OCID=$(grep "tenancy=" $OCI_CONFIG_FILE | cut -d'=' -f2)
echo "OCI_TENANCY_OCID=$TENANCY_OCID"

# 3. OCI_REGION
REGION=$(grep "region=" $OCI_CONFIG_FILE | cut -d'=' -f2)
echo "OCI_REGION=$REGION"

# 4. OCI_FINGERPRINT
FINGERPRINT=$(grep "fingerprint=" $OCI_CONFIG_FILE | cut -d'=' -f2)
echo "OCI_FINGERPRINT=$FINGERPRINT"

# 5. OCI_PRIVATE_KEY
KEY_FILE=$(grep "key_file=" $OCI_CONFIG_FILE | cut -d'=' -f2)
if [ -f "$KEY_FILE" ]; then
    echo "OCI_PRIVATE_KEY="
    cat "$KEY_FILE"
else
    echo "❌ Private key file not found: $KEY_FILE"
fi

# 6. OCI_COMPARTMENT_ID (root compartment = tenancy)
echo "OCI_COMPARTMENT_ID=$TENANCY_OCID"

# 7. SSH_PUBLIC_KEY
echo ""
if [ -f ~/.ssh/id_rsa.pub ]; then
    echo "SSH_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)"
elif [ -f ~/.ssh/id_ed25519.pub ]; then
    echo "SSH_PUBLIC_KEY=$(cat ~/.ssh/id_ed25519.pub)"
else
    echo "❌ SSH public key not found. Generate one with:"
    echo "   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa"
    echo "   Then run this script again"
fi

echo ""
echo "📝 Instructions:"
echo "1. Copy each value above"
echo "2. Go to GitHub repo → Settings → Secrets and variables → Actions"
echo "3. Click 'New repository secret'"
echo "4. Add each secret with exact name and value"
echo ""
echo "⚠️  Keep these values secure and never commit them to code!"