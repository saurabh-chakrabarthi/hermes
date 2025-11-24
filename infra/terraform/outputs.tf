output "instance_id" {
  description = "OCID of the instance"
  value = local.should_create_instance ? oci_core_instance.hermes_instance[0].id : data.oci_core_instances.existing_instances.instances[0].id
}

output "instance_public_ip" {
  description = "Public IP of the Hermes Payment Portal instance"
  value = local.should_create_instance ? oci_core_instance.hermes_instance[0].public_ip : local.existing_public_ip
}

output "private_ip" {
  description = "Private IP address of the instance"
  value = local.should_create_instance ? oci_core_instance.hermes_instance[0].private_ip : (length(data.oci_core_vnic.existing_vnic) > 0 ? data.oci_core_vnic.existing_vnic[0].private_ip_address : "")
}

output "instance_state" {
  description = "Current state of the instance"
  value = local.should_create_instance ? oci_core_instance.hermes_instance[0].state : data.oci_core_instances.existing_instances.instances[0].state
}

output "security_validation" {
  description = "Security rules validation status"
  value = {
    port_22_ssh      = local.port_22_allowed ? "✅ ALLOWED" : "❌ BLOCKED"
    port_8080_dashboard = local.port_8080_allowed ? "✅ ALLOWED" : "❌ BLOCKED"
    port_9292_server = local.port_9292_allowed ? "✅ ALLOWED" : "❌ BLOCKED"
    all_ports_open   = local.security_validation_passed ? "✅ ALL REQUIRED PORTS OPEN" : "❌ SOME PORTS BLOCKED"
  }
}

output "deployment_urls" {
  description = "Application URLs"
  value = {
    payment_server = "http://${local.should_create_instance ? oci_core_instance.hermes_instance[0].public_ip : local.existing_public_ip}:9292"
    dashboard      = "http://${local.should_create_instance ? oci_core_instance.hermes_instance[0].public_ip : local.existing_public_ip}:8080"
  }
}