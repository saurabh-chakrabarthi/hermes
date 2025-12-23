terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
  
  backend "local" {
    path = "/tmp/terraform.tfstate"
  }
}

provider "oci" {
  region              = var.region
  user_ocid           = var.user_ocid
  fingerprint         = var.fingerprint
  private_key         = var.private_key
  tenancy_ocid        = var.tenancy_ocid
}



# Get availability domain
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Check for existing instances
data "oci_core_instances" "existing_instances" {
  compartment_id = var.compartment_id
  display_name   = "hermes-payment-portal"
  state          = "RUNNING"
}

# Get VNIC attachments for existing instance
data "oci_core_vnic_attachments" "existing_vnic_attachments" {
  compartment_id = var.compartment_id
  instance_id    = length(data.oci_core_instances.existing_instances.instances) > 0 ? data.oci_core_instances.existing_instances.instances[0].id : null
}

# Get VNIC details for existing instance
data "oci_core_vnic" "existing_vnic" {
  count   = length(data.oci_core_vnic_attachments.existing_vnic_attachments.vnic_attachments) > 0 ? 1 : 0
  vnic_id = data.oci_core_vnic_attachments.existing_vnic_attachments.vnic_attachments[0].vnic_id
}

# Only create instance if none exists
locals {
  should_create_instance = length(data.oci_core_instances.existing_instances.instances) == 0
  existing_public_ip     = length(data.oci_core_vnic.existing_vnic) > 0 ? data.oci_core_vnic.existing_vnic[0].public_ip_address : ""
}

# Get Ubuntu image
data "oci_core_images" "ubuntu_images" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Use existing VCN
data "oci_core_vcns" "existing_vcn" {
  compartment_id = var.compartment_id
  display_name   = "hermes-payment-portal-vcn"
}

# Use existing subnet
data "oci_core_subnets" "existing_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = data.oci_core_vcns.existing_vcn.virtual_networks[0].id
}

# Create instance only if none exists
resource "oci_core_instance" "hermes_instance" {
  count = local.should_create_instance ? 1 : 0
  
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "hermes-payment-portal"
  shape               = "VM.Standard.E2.1.Micro"
  
  lifecycle {
    create_before_destroy = false
  }

  create_vnic_details {
    subnet_id        = data.oci_core_subnets.existing_subnet.subnets[0].id
    display_name     = "hermes-vnic"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_images.images[0].id
    boot_volume_size_in_gbs = 50
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    deployment_trigger  = var.deployment_trigger
    user_data = base64encode(templatefile("${path.module}/../scripts/setup-k3s.sh", {
      GITHUB_OWNER      = var.github_owner
      MONGODB_PASSWORD  = var.mongodb_password
      MONGODB_USER      = var.mongodb_user
      MONGODB_CLUSTER   = var.mongodb_cluster
      MONGODB_DATABASE  = var.mongodb_database
    }))
  }

  timeouts {
    create = "15m"
  }
}

# Get security lists for the subnet
data "oci_core_security_lists" "subnet_security_lists" {
  compartment_id = var.compartment_id
  vcn_id         = data.oci_core_vcns.existing_vcn.virtual_networks[0].id
}

# Validate security rules
locals {
  required_ports = [22, 30080, 30092]
  
  # Get all ingress rules from all security lists
  all_ingress_rules = flatten([
    for sl in data.oci_core_security_lists.subnet_security_lists.security_lists : [
      for rule in sl.ingress_security_rules : {
        protocol = rule.protocol
        source   = rule.source
        tcp_options = rule.tcp_options
      }
    ]
  ])
  
  # Check if each required port is allowed
  port_22_allowed = anytrue([
    for rule in local.all_ingress_rules :
    rule.protocol == "6" && rule.source == "0.0.0.0/0" && (
      length(rule.tcp_options) == 0 || 
      anytrue([for opt in rule.tcp_options : 
        (opt.min == 22 && opt.max == 22) || 
        (opt.min <= 22 && opt.max >= 22)
      ])
    )
  ])
  
  port_30080_allowed = anytrue([
    for rule in local.all_ingress_rules :
    rule.protocol == "6" && rule.source == "0.0.0.0/0" && (
      length(rule.tcp_options) == 0 || 
      anytrue([for opt in rule.tcp_options : 
        (opt.min == 30080 && opt.max == 30080) || 
        (opt.min <= 30080 && opt.max >= 30080)
      ])
    )
  ])
  
  port_30092_allowed = anytrue([
    for rule in local.all_ingress_rules :
    rule.protocol == "6" && rule.source == "0.0.0.0/0" && (
      length(rule.tcp_options) == 0 || 
      anytrue([for opt in rule.tcp_options : 
        (opt.min == 30092 && opt.max == 30092) || 
        (opt.min <= 30092 && opt.max >= 30092)
      ])
    )
  ])
  
  security_validation_passed = local.port_22_allowed && local.port_30080_allowed && local.port_30092_allowed
}



