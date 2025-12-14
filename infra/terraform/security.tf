# Update security list to allow NodePort access
resource "oci_core_security_list" "hermes_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = data.oci_core_vcns.existing_vcn.virtual_networks[0].id
  display_name   = "hermes-security-list"

  # Allow SSH
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = false
    description = "SSH access"
    
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Allow NodePort 30080 (Dashboard)
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = false
    description = "Dashboard NodePort"
    
    tcp_options {
      min = 30080
      max = 30080
    }
  }

  # Allow NodePort 30092 (Server)
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = false
    description = "Server NodePort"
    
    tcp_options {
      min = 30092
      max = 30092
    }
  }

  # Allow all egress
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
    description = "Allow all outbound"
  }
}

# Attach security list to subnet
data "oci_core_subnet" "hermes_subnet" {
  subnet_id = data.oci_core_subnets.existing_subnet.subnets[0].id
}

resource "oci_core_subnet" "hermes_subnet_update" {
  cidr_block     = data.oci_core_subnet.hermes_subnet.cidr_block
  compartment_id = var.compartment_id
  vcn_id         = data.oci_core_vcns.existing_vcn.virtual_networks[0].id
  display_name   = data.oci_core_subnet.hermes_subnet.display_name
  
  security_list_ids = concat(
    data.oci_core_subnet.hermes_subnet.security_list_ids,
    [oci_core_security_list.hermes_security_list.id]
  )

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}
