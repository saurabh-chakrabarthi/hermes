output "instance_id" {
  description = "OCID of the instance"
  value = local.should_create_instance ? oci_core_instance.hermes_instance[0].id : data.oci_core_instances.existing_instances.instances[0].id
}

output "private_ip" {
  description = "Private IP address of the instance"
  value = local.should_create_instance ? oci_core_instance.hermes_instance[0].private_ip : data.oci_core_instances.existing_instances.instances[0].private_ip
}

output "instance_state" {
  description = "Current state of the instance"
  value = local.should_create_instance ? oci_core_instance.hermes_instance[0].state : data.oci_core_instances.existing_instances.instances[0].state
}