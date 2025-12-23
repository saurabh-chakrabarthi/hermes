provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

locals {
  atlas_whitelist_cidr = var.hermes_static_ip != "" ? "${var.hermes_static_ip}/32" : "0.0.0.0/0"
}

# Create an IP allowlist entry (uses hermes_static_ip/32 when provided, otherwise opens 0.0.0.0/0)
# This is guarded by a count so it only runs when atlas keys and project id are provided.
resource "mongodbatlas_project_ip_allowlist" "allow_hermes" {
  count      = (var.atlas_public_key != "" && var.atlas_private_key != "" && var.atlas_project_id != "") ? 1 : 0
  project_id = var.atlas_project_id
  cidr_block = local.atlas_whitelist_cidr
  comment    = "Allow Hermes static IP or open access (configured by Terraform)"
}

# Create a database user in Atlas (reads credentials from TF vars)
resource "mongodbatlas_database_user" "app_user" {
  count      = (var.atlas_public_key != "" && var.atlas_private_key != "" && var.atlas_project_id != "") ? 1 : 0
  project_id = var.atlas_project_id
  username   = var.mongodb_user
  password   = var.mongodb_password

  roles {
    role_name     = "readWrite"
    database_name = var.mongodb_database
  }

  # Grant access from any host by mapping the built IP allowlist above (Atlas matches by CIDR entries)
}

output "atlas_ip_allowlist_added" {
  value = (length(mongodbatlas_project_ip_allowlist.allow_hermes) > 0) ? mongodbatlas_project_ip_allowlist.allow_hermes[0].cidr_block : "not-configured"
}
