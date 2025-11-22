# Infrastructure Setup Scripts

## setup-nodejs.sh

Cloud-init script that runs on OCI instance creation. Installs and configures:

- Node.js 18.x
- Git
- Clones the repository
- Installs npm dependencies
- Creates systemd service for the Node.js server
- Starts the payment server on port 9292

This script is automatically executed by Terraform during instance provisioning.

## setup-dev.sh

Local development setup script (if needed for manual testing).
