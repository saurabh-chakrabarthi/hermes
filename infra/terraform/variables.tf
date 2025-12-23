variable "region" {
  description = "OCI region"
  type        = string
  default     = "us-ashburn-1"
}

variable "compartment_id" {
  description = "OCI compartment OCID"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

variable "mongodb_password" {
  description = "MongoDB password"
  type        = string
  sensitive   = true
}

variable "user_ocid" {
  description = "OCI user OCID"
  type        = string
}

variable "fingerprint" {
  description = "OCI API key fingerprint"
  type        = string
}

variable "private_key" {
  description = "OCI private key content"
  type        = string
  sensitive   = true
}

variable "tenancy_ocid" {
  description = "OCI tenancy OCID"
  type        = string
}

variable "deployment_trigger" {
  description = "Trigger to force instance replacement"
  type        = string
  default     = "6"
}

variable "github_owner" {
  description = "GitHub repository owner for container registry"
  type        = string
}

variable "mongodb_user" {
  description = "MongoDB username"
  type        = string
}

variable "mongodb_cluster" {
  description = "MongoDB cluster host"
  type        = string
}

variable "mongodb_database" {
  description = "MongoDB database name"
  type        = string
}

variable "atlas_public_key" {
  description = "MongoDB Atlas API public key (optional, for provisioning via Terraform)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "atlas_private_key" {
  description = "MongoDB Atlas API private key (optional, for provisioning via Terraform)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "atlas_project_id" {
  description = "MongoDB Atlas project id (optional)"
  type        = string
  default     = ""
}

variable "hermes_static_ip" {
  description = "Static IP for the Hermes deployment (used to whitelist in Atlas). Provide without /32."
  type        = string
  default     = ""
}



