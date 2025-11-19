provider "oci" {}

resource "oci_core_instance" "generated_oci_core_instance" {
	agent_config {
		is_management_disabled = "false"
		is_monitoring_disabled = "false"
		plugins_config {
			desired_state = "DISABLED"
			name = "Vulnerability Scanning"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Management Agent"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Custom Logs Monitoring"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute RDMA GPU Monitoring"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Monitoring"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute HPC RDMA Auto-Configuration"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute HPC RDMA Authentication"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Cloud Guard Workload Protection"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Block Volume Management"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Bastion"
		}
	}
	availability_config {
		recovery_action = "RESTORE_INSTANCE"
	}
	availability_domain = var.availability_domain
	compartment_id = var.compartment_id
	create_vnic_details {
		assign_ipv6ip = "false"
		assign_private_dns_record = "true"
		assign_public_ip = "true"
		subnet_id = var.subnet_id
	}
	display_name = "hermes-payment-portal-server"
	instance_options {
		are_legacy_imds_endpoints_disabled = "false"
	}
	is_pv_encryption_in_transit_enabled = "true"
	metadata = {
		"ssh_authorized_keys" = var.ssh_public_key
		"user_data" = "I2Nsb3VkLWNvbmZpZwpwYWNrYWdlX3VwZGF0ZTogdHJ1ZQpwYWNrYWdlX3VwZ3JhZGU6IHRydWUKCnBhY2thZ2VzOgogIC0gcnVieQogIC0gcnVieS1kZXYKICAtIGJ1aWxkLWVzc2VudGlhbAogIC0gc3FsaXRlMwogIC0gbGlic3FsaXRlMy1kZXYKICAtIGdpdAoKcnVuY21kOgogIC0gZ2VtIGluc3RhbGwgYnVuZGxlcgogIC0gbWtkaXIgLXAgL2hvbWUvdWJ1bnR1L3BheW1lbnQtcG9ydGFsCiAgLSBjaG93biB1YnVudHU6dWJ1bnR1IC9ob21lL3VidW50dS9wYXltZW50LXBvcnRhbAogIC0gc3VkbyAtdSB1YnVudHUgZ2l0IGNsb25lIGh0dHBzOi8vZ2l0aHViLmNvbS9zYXVyYWJoLWNoYWtyYWJhcnRoaS9oZXJtZXMuZ2l0IC9ob21lL3VidW50dS9wYXltZW50LXBvcnRhbAogIC0gY2QgL2hvbWUvdWJ1bnR1L3BheW1lbnQtcG9ydGFsL3NlcnZlciAmJiBzdWRvIC11IHVidW50dSBidW5kbGUgaW5zdGFsbAogIC0gY2QgL2hvbWUvdWJ1bnR1L3BheW1lbnQtcG9ydGFsL3NlcnZlciAmJiBzdWRvIC11IHVidW50dSBidW5kbGUgZXhlYyByYWtlIGRiOmNyZWF0ZSBkYjptaWdyYXRlCiAgLSBjcCAvaG9tZS91YnVudHUvcGF5bWVudC1wb3J0YWwvaW5mcmEvc2NyaXB0cy9wYXltZW50LXNlcnZlci5zZXJ2aWNlIC9ldGMvc3lzdGVtZC9zeXN0ZW0vCiAgLSBzeXN0ZW1jdGwgZGFlbW9uLXJlbG9hZAogIC0gc3lzdGVtY3RsIGVuYWJsZSBwYXltZW50LXNlcnZlcgogIC0gc3lzdGVtY3RsIHN0YXJ0IHBheW1lbnQtc2VydmVyCiAgLSB1ZncgYWxsb3cgOTI5MgogIC0gZWNobyAiU2V0dXAgY29tcGxldGUhIFNlcnZlciBydW5uaW5nIG9uIHBvcnQgOTI5MiIgPiAvaG9tZS91YnVudHUvc2V0dXAtY29tcGxldGUubG9n"
	}
	shape = "VM.Standard.A1.Flex"
	shape_config {
		memory_in_gbs = "24"
		ocpus = "4"
	}
	source_details {
		boot_volume_size_in_gbs = "50"
		boot_volume_vpus_per_gb = "10"
		source_id = var.source_id
		source_type = "image"
	}
}