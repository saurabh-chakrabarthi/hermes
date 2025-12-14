# Update existing default security list to allow NodePort access
resource "oci_core_default_security_list" "hermes_default_security_list" {
  manage_default_resource_id = data.oci_core_subnets.existing_subnet.subnets[0].security_list_ids[0]

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
