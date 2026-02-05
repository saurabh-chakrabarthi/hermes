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

# Create instance with deployment trigger for replacement
resource "oci_core_instance" "hermes_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "hermes-payment-portal"
  shape               = "VM.Standard.E2.1.Micro"
  
  lifecycle {
    create_before_destroy = true
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
    deployment_trigger  = var.deployment_trigger  # Changing this forces instance replacement
    user_data = base64encode(templatefile("${path.module}/../scripts/setup-docker.sh", {
      GITHUB_OWNER      = var.github_owner
      GITHUB_TOKEN      = var.github_token
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
  required_ports = [22, 8080, 9292]
  
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
  
  port_8080_allowed = anytrue([
    for rule in local.all_ingress_rules :
    rule.protocol == "6" && rule.source == "0.0.0.0/0" && (
      length(rule.tcp_options) == 0 || 
      anytrue([for opt in rule.tcp_options : 
        (opt.min == 8080 && opt.max == 8080) || 
        (opt.min <= 8080 && opt.max >= 8080)
      ])
    )
  ])
  
  port_9292_allowed = anytrue([
    for rule in local.all_ingress_rules :
    rule.protocol == "6" && rule.source == "0.0.0.0/0" && (
      length(rule.tcp_options) == 0 || 
      anytrue([for opt in rule.tcp_options : 
        (opt.min == 9292 && opt.max == 9292) || 
        (opt.min <= 9292 && opt.max >= 9292)
      ])
    )
  ])
  
  security_validation_passed = local.port_22_allowed && local.port_8080_allowed && local.port_9292_allowed
}



