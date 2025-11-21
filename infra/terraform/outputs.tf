output "instance_id" {
  description = "OCID of the created instance"
  value       = oci_core_instance.hermes_instance.id
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = oci_core_instance.hermes_instance.private_ip
}

output "instance_state" {
  description = "Current state of the instance"
  value       = oci_core_instance.hermes_instance.state
}