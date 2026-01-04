# Security Configuration

## Network Security Improvements

### Previous Issues ❌

The original security configuration had several critical vulnerabilities:

1. **SSH Access**: `0.0.0.0/0` - Allowed SSH from anywhere in the world
2. **Web Access**: `0.0.0.0/0` - Allowed web traffic from any IP
3. **Egress Rules**: `protocol=all, destination=0.0.0.0/0` - Allowed all outbound traffic

### Current Security ✅

#### Ingress Rules (Inbound Traffic)

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22 | TCP | `var.allowed_ssh_cidr` | SSH access (restricted) |
| 8080 | TCP | `var.allowed_web_cidr` | Dashboard access (restricted) |
| 9292 | TCP | `var.allowed_web_cidr` | Payment API access (restricted) |

#### Egress Rules (Outbound Traffic)

| Port | Protocol | Destination | Purpose |
|------|----------|-------------|---------|
| 443 | TCP | `0.0.0.0/0` | HTTPS (MongoDB Atlas, updates) |
| 80 | TCP | `0.0.0.0/0` | HTTP (package updates) |
| 53 | UDP | `0.0.0.0/0` | DNS resolution |
| 27017 | TCP | `0.0.0.0/0` | MongoDB Atlas connection |

## Configuration Variables

The security variables can be configured in **three ways** (in order of precedence):

### 1. GitHub Secrets (Recommended for CI/CD)

Add these secrets in GitHub → Settings → Secrets → Actions:

```
ALLOWED_SSH_CIDR=<your_ip_range>
ALLOWED_WEB_CIDR=<your_ip_range>
```

### 2. terraform.tfvars File (Local Development)

Create `infra/terraform/terraform.tfvars`:

```hcl
# Security Configuration
allowed_ssh_cidr = "<your_ip_range>"    # Your office/home IP range
allowed_web_cidr = "<your_ip_range>"    # Allowed IP range for web access
```

### 3. Default Values (Insecure - Not Recommended)

If neither GitHub Secrets nor terraform.tfvars are set, defaults to `0.0.0.0/0` (allows all IPs).

### Required Security Variables

```hcl
# Get your current IP: curl ifconfig.me
# Replace <your_ip> with your actual IP address

# Option 1: Exact IP (most secure, may break if IP changes)
allowed_ssh_cidr = "<your_ip>/32"   # Your current public IP
allowed_web_cidr = "<your_ip>/32"   # Your current public IP

# Option 2: ISP range (handles IP changes, less secure)
allowed_ssh_cidr = "<your_isp_range>/16"      # Your ISP's IP range
allowed_web_cidr = "<your_isp_range>/16"      # Your ISP's IP range
```

### Example Configurations

#### Your Specific Case
```hcl
# Get your current public IP first: curl ifconfig.me
# Replace <your_ip> with your actual IP address
allowed_ssh_cidr = "<your_ip>/32"   # Only your specific IP
allowed_web_cidr = "<your_ip>/32"   # Only your specific IP
```

#### ISP Range (Recommended for Dynamic IP)
```hcl
# Replace <your_isp_range> with your ISP's IP block
allowed_ssh_cidr = "<your_isp_range>/16"      # Handles IP changes
allowed_web_cidr = "<your_isp_range>/16"      # Handles IP changes
```

#### Single IP Access
```hcl
allowed_ssh_cidr = "98.207.254.100/32"  # Only one specific IP
allowed_web_cidr = "98.207.254.100/32"
```

#### Office Network Access
```hcl
allowed_ssh_cidr = "98.207.254.0/24"    # Entire office subnet
allowed_web_cidr = "98.207.254.0/24"
```

#### ISP Range (Handles Dynamic IP Changes)
```hcl
# If your ISP assigns IPs from 98.207.0.0 to 98.207.255.255
allowed_ssh_cidr = "98.207.0.0/16"      # Broader ISP range
allowed_web_cidr = "98.207.0.0/16"
```

#### Multiple IP Ranges (requires multiple rules)
For multiple non-contiguous IP ranges, you'll need to modify the Terraform configuration to add additional ingress rules.

## Dynamic IP Solutions

### Problem: Changing IP Addresses
If your IP changes frequently (common with residential ISPs), you have several options:

### Option 1: Use ISP IP Range
```hcl
# Find your ISP's IP range using: whois $(curl -s ifconfig.me)
allowed_ssh_cidr = "98.207.0.0/16"  # Broader ISP range
```

### Option 2: DNS/Hostname (Not Directly Supported)
**OCI Security Lists only accept IP addresses/CIDR blocks, NOT hostnames.**

**Why localhost won't work:**
- `localhost` (127.0.0.1) = your local machine
- Your OCI VM is on the internet, not your local network
- Security rules need your **public internet IP** (get with `curl ifconfig.me`)

Workarounds:
1. **Dynamic DNS + Script**: Use a service like DuckDNS, then run a script to resolve and update Terraform
2. **VPN**: Use a VPN with static IP
3. **Bastion Host**: Set up a jump server with known IP

### Option 3: Automated IP Update Script
```bash
#!/bin/bash
# update-security-rules.sh
CURRENT_IP=$(curl -s ifconfig.me)
echo "Current IP: $CURRENT_IP"

# Update GitHub Secret
gh secret set ALLOWED_SSH_CIDR --body "$CURRENT_IP/32"
gh secret set ALLOWED_WEB_CIDR --body "$CURRENT_IP/32"

# Trigger deployment
gh workflow run deploy.yml
```

## Security Best Practices

### 1. IP Whitelisting
- Never use `0.0.0.0/0` for production systems
- Use the smallest CIDR block possible
- Regularly review and update allowed IPs

### 2. SSH Security
- Use key-based authentication only
- Disable password authentication
- Consider using a bastion host for additional security

### 3. Web Access
- Consider using a CDN/WAF for additional protection
- Implement rate limiting at the application level
- Use HTTPS in production (add SSL termination)

### 4. Monitoring
- Enable OCI logging for security events
- Monitor failed authentication attempts
- Set up alerts for unusual traffic patterns

## Deployment Security

### GitHub Secrets
All sensitive data is stored in GitHub Secrets:
- `OCI_*` - OCI authentication credentials
- `MONGODB_*` - Database connection details
- `SSH_PUBLIC_KEY` - SSH key for instance access

### Container Security
- Images are scanned for vulnerabilities
- No secrets in container images
- Runtime secrets via environment variables only

## Compliance Notes

This configuration helps meet:
- **Principle of Least Privilege**: Minimal required access
- **Defense in Depth**: Multiple security layers
- **Network Segmentation**: Restricted traffic flows

## Migration from Insecure Setup

If migrating from the previous `0.0.0.0/0` configuration:

1. Update `terraform.tfvars` with your IP ranges
2. Run `terraform plan` to review changes
3. Run `terraform apply` to update security rules
4. Test connectivity from allowed IPs only
5. Verify blocked access from other IPs

## Troubleshooting

### Cannot SSH to Instance
- Verify your IP is in `allowed_ssh_cidr`
- Check if your public IP has changed
- Temporarily expand CIDR range for testing

### Cannot Access Web Services
- Verify your IP is in `allowed_web_cidr`
- Check firewall rules on your local network
- Test from different network/IP

### Services Cannot Connect to MongoDB
- MongoDB Atlas allows `0.0.0.0/0` by default
- Verify MongoDB Atlas IP whitelist includes VM's public IP
- Check MongoDB connection string and credentials