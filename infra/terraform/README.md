# Hermes Payment Portal - OCI Terraform

Deploy the Hermes Payment Portal to Oracle Cloud Infrastructure using Terraform.

## Quick Start

```bash
cd infra/terraform
terraform init
terraform plan
terraform apply
```

## Configuration

All OCIDs are pre-configured with default values. Override in `terraform.tfvars` if needed:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

## Outputs

After deployment, you'll get:
- Instance OCID
- Public IP address
- Private IP address
- Instance state

## Instance Details

- **Shape**: VM.Standard.A1.Flex (4 OCPUs, 24GB RAM)
- **OS**: Ubuntu with Ruby environment
- **Port**: 9292 (automatically opened)
- **Auto-setup**: Payment portal deployed via cloud-init

Access your portal at: `http://<public_ip>:9292`