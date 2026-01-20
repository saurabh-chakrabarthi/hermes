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
  default     = "10"
}

variable "github_owner" {
  description = "GitHub repository owner for container registry"
  type        = string
}

variable "github_token" {
  description = "GitHub token for container registry"
  type        = string
  sensitive   = true
}

# Security variables for network access control
variable "allowed_ssh_cidr" {
  description = "CIDR block allowed for SSH access (e.g., your office IP range)"
  type        = string
  default     = "0.0.0.0/0"  # Change this to your specific IP range
}

variable "allowed_web_cidr" {
  description = "CIDR block allowed for web access to dashboard and API"
  type        = string
  default     = "0.0.0.0/0"  # Change this to your specific IP range or customer IP ranges
}



