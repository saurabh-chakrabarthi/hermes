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

# Create/Replace instance (always creates fresh instance)
resource "oci_core_instance" "hermes_instance" {
  
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
    user_data = base64encode(file("${path.module}/../scripts/setup-nodejs.sh"))
  }

  timeouts {
    create = "15m"
  }
}

output "instance_public_ip" {
  description = "Public IP of the Hermes Payment Portal instance"
  value = oci_core_instance.hermes_instance.public_ip
}

