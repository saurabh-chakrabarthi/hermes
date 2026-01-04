# Security list with restricted access
resource "oci_core_default_security_list" "hermes_default_security_list" {
  manage_default_resource_id = data.oci_core_subnets.existing_subnet.subnets[0].security_list_ids[0]

  # SSH access - restrict to your IP range
  ingress_security_rules {
    protocol    = "6"
    source      = var.allowed_ssh_cidr
    stateless   = false
    description = "SSH access from allowed IPs"
    
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Dashboard access - restrict to specific IPs/ranges
  ingress_security_rules {
    protocol    = "6"
    source      = var.allowed_web_cidr
    stateless   = false
    description = "Dashboard access from allowed IPs"
    
    tcp_options {
      min = 8080
      max = 8080
    }
  }

  # Payment server access - restrict to specific IPs/ranges
  ingress_security_rules {
    protocol    = "6"
    source      = var.allowed_web_cidr
    stateless   = false
    description = "Payment server access from allowed IPs"
    
    tcp_options {
      min = 9292
      max = 9292
    }
  }

  # HTTPS outbound (for MongoDB Atlas, package updates)
  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
    stateless   = false
    description = "HTTPS outbound"
    
    tcp_options {
      min = 443
      max = 443
    }
  }

  # HTTP outbound (for package updates)
  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
    stateless   = false
    description = "HTTP outbound"
    
    tcp_options {
      min = 80
      max = 80
    }
  }

  # DNS outbound
  egress_security_rules {
    protocol    = "17"
    destination = "0.0.0.0/0"
    stateless   = false
    description = "DNS outbound"
    
    udp_options {
      min = 53
      max = 53
    }
  }

  # MongoDB Atlas (port 27017)
  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
    stateless   = false
    description = "MongoDB Atlas access"
    
    tcp_options {
      min = 27017
      max = 27017
    }
  }
}
