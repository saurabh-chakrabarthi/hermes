MongoDB / Atlas provisioning (optional)
====================================

This project currently uses a hosted MongoDB cluster (Atlas) and expects the cluster host, database name, user and password to be provided to Terraform via `TF_VAR_*` or GitHub Secrets.

If you want Terraform to also provision MongoDB Atlas resources (project, cluster, database user), follow these steps:

1. Create MongoDB Atlas API keys (Public & Private) in your Atlas organization.
2. Add the keys to GitHub Secrets as `ATLAS_PUBLIC_KEY` and `ATLAS_PRIVATE_KEY` (and `ATLAS_PROJECT_ID` if you already have a project).
3. Enable the MongoDB Atlas Terraform provider by adding a provider block and resources to `infra/terraform` (example below).

Example provider snippet (add to your Terraform `main.tf` or a new file):

```hcl
terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.4"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

# Example: create a database user in an existing Atlas project
resource "mongodbatlas_database_user" "app_user" {
  project_id   = var.atlas_project_id
  username     = var.mongodb_user
  password     = var.mongodb_password
  roles {
    role_name     = "readWrite"
    database_name = var.mongodb_database
  }
}
```

Notes:
- Creating a cluster with Terraform is supported but may take many minutes and incur costs.
- Terraform will manage Atlas resources; use GitHub Secrets to store Atlas API keys.
- Provisioning the database itself is usually achieved by creating users and/or inserting initial data; Atlas will create DBs on first write.

If you want, I can scaffold the provider block and example resources and wire GitHub Actions to pass `TF_VAR_atlas_public_key`/`TF_VAR_atlas_private_key` from Secrets.
