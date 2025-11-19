output "instance_id" {
  description = "OCID of the created instance"
  value       = oci_core_instance.generated_oci_core_instance.id
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = oci_core_instance.generated_oci_core_instance.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = oci_core_instance.generated_oci_core_instance.private_ip
}

output "instance_state" {
  description = "Current state of the instance"
  value       = oci_core_instance.generated_oci_core_instance.state
}