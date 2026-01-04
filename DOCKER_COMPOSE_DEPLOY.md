# Docker Compose Deployment - Simplified
# Add this to .github/workflows/deploy.yml

# In the Deploy Infrastructure step, replace the env section with:
env:
  TF_VAR_user_ocid: ${{ secrets.OCI_USER_OCID }}
  TF_VAR_fingerprint: ${{ secrets.OCI_FINGERPRINT }}
  TF_VAR_tenancy_ocid: ${{ secrets.OCI_TENANCY_OCID }}
  TF_VAR_region: ${{ secrets.OCI_REGION }}
  TF_VAR_private_key: ${{ secrets.OCI_PRIVATE_KEY }}
  TF_VAR_compartment_id: ${{ secrets.OCI_COMPARTMENT_ID }}
  TF_VAR_ssh_public_key: ${{ secrets.SSH_PUBLIC_KEY }}
  TF_VAR_mongodb_password: ${{ secrets.MONGODB_PASSWORD }}
  TF_VAR_mongodb_user: hermes_db_user
  TF_VAR_mongodb_cluster: <mongodb_cluster_hostname>
  TF_VAR_mongodb_database: hermes_payments
  TF_VAR_github_owner: ${{ github.repository_owner }}
  TF_VAR_github_token: ${{ secrets.GITHUB_TOKEN }}

# In Wait for Docker Services, change port from 30092 to 9292
# In Health Check, change ports from 30092/30080 to 9292/8080
