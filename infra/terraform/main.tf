terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

provider "oci" {
  # Uses OCI CLI configuration from ~/.oci/config
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

# Create VCN
resource "oci_core_vcn" "hermes_vcn" {
  compartment_id = var.compartment_id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "hermes-vcn"
  dns_label      = "hermesvcn"
}

# Create Internet Gateway
resource "oci_core_internet_gateway" "hermes_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.hermes_vcn.id
  display_name   = "hermes-igw"
}

# Create Route Table
resource "oci_core_route_table" "hermes_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.hermes_vcn.id
  display_name   = "hermes-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.hermes_igw.id
  }
}

# Create Subnet
resource "oci_core_subnet" "hermes_subnet" {
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.hermes_vcn.id
  cidr_block          = "10.0.1.0/24"
  display_name        = "hermes-subnet"
  dns_label           = "hermessubnet"
  route_table_id      = oci_core_route_table.hermes_rt.id
  security_list_ids   = [oci_core_security_list.hermes_sl.id]
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

# Create DB Subnet
resource "oci_core_subnet" "hermes_db_subnet" {
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.hermes_vcn.id
  cidr_block          = "10.0.2.0/24"
  display_name        = "hermes-db-subnet"
  dns_label           = "hermesdbsubnet"
  route_table_id      = oci_core_route_table.hermes_rt.id
  security_list_ids   = [oci_core_security_list.hermes_db_sl.id]
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  prohibit_public_ip_on_vnic = true
}

# Create Security List for App
resource "oci_core_security_list" "hermes_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.hermes_vcn.id
  display_name   = "hermes-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 9292
      max = 9292
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 8080
      max = 8080
    }
  }


}

# Create Security List for Database
resource "oci_core_security_list" "hermes_db_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.hermes_vcn.id
  display_name   = "hermes-db-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "10.0.1.0/24"
    tcp_options {
      min = 3306
      max = 3306
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "10.0.1.0/24"
    tcp_options {
      min = 33060
      max = 33060
    }
  }
}

# Create MySQL HeatWave Database System (Free Tier)
resource "oci_mysql_mysql_db_system" "hermes_mysql" {
  compartment_id = var.compartment_id
  display_name   = "hermes-mysql-free"
  description    = "MySQL HeatWave Free Tier"
  
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape_name         = "MySQL.Free"
  subnet_id          = oci_core_subnet.hermes_db_subnet.id
  
  admin_password = var.db_password
  admin_username = "admin"
  
  data_storage_size_in_gb = 50
  
  configuration_id = data.oci_mysql_mysql_configurations.free_config.configurations[0].id
  
  backup_policy {
    is_enabled        = false
    retention_in_days = 1
  }
  
  maintenance {
    window_start_time = "SUNDAY 14:30"
  }
}

# Get MySQL configurations
data "oci_mysql_mysql_configurations" "free_config" {
  compartment_id = var.compartment_id
  type          = ["DEFAULT"]
  shape_name    = "MySQL.Free"
}

# Create Compute Instance
resource "oci_core_instance" "hermes_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "hermes-payment-portal"
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    subnet_id        = oci_core_subnet.hermes_subnet.id
    display_name     = "hermes-vnic"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_images.images[0].id
    boot_volume_size_in_gbs = 47
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/../scripts/setup-server.sh", {
      db_host     = oci_mysql_mysql_db_system.hermes_mysql.ip_address
      db_password = var.db_password
    }))
  }

  timeouts {
    create = "15m"
  }
  
  depends_on = [oci_mysql_mysql_db_system.hermes_mysql]
}

output "instance_public_ip" {
  description = "Public IP of the Hermes Payment Portal instance"
  value       = oci_core_instance.hermes_instance.public_ip
}

output "mysql_ip" {
  description = "Private IP of MySQL HeatWave instance"
  value       = oci_mysql_mysql_db_system.hermes_mysql.ip_address
}

output "mysql_port" {
  description = "MySQL port"
  value       = oci_mysql_mysql_db_system.hermes_mysql.port
}

output "database_connection" {
  description = "Database connection details"
  value = {
    host     = oci_mysql_mysql_db_system.hermes_mysql.ip_address
    port     = oci_mysql_mysql_db_system.hermes_mysql.port
    username = "admin"
    database = "hermes_payments"
  }
  sensitive = false
}