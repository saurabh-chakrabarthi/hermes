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

variable "db_password" {
  description = "MySQL database password"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
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
  default     = "3"
}

variable "github_owner" {
  description = "GitHub repository owner for container registry"
  type        = string
}

