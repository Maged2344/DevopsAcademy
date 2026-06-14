# Terraform Infrastructure as Code - DevOps Academy

Multi-cloud infrastructure provisioning for DevOps Academy using HashiCorp Terraform. Deploy the complete stack across **AWS**, **GCP**, **Azure**, **Alibaba Cloud**, or **Oracle Cloud** with a single variable change.

## Features

- **Multi-Cloud Support**: AWS, GCP, Azure, Alibaba Cloud, Oracle Cloud
- **Infrastructure Components**:
  - Virtual Machines (EC2, Compute Engine, Azure VMs, ECS, OCI Compute)
  - Virtual Networks (VPC/VNet with subnets and security groups)
  - Persistent Storage (EBS, Persistent Disks, Managed Disks, Cloud Disks, Block Storage)
  - DNS Management (Route53, Cloud DNS, Azure DNS, Alibaba DNS, Oracle DNS, Cloudflare)
  - Automated Backups (DLM, Snapshots, Volume Backups)
- **Docker-Ready**: Automatic installation of Docker and Docker Compose via user_data script
- **Modular Design**: Reusable modules for compute, networking, storage, and DNS
- **Environment Management**: Pre-configured `.tfvars` files for each cloud provider
- **Provider Validated**: All providers correctly sourced (`aliyun/alicloud`, `oracle/oci`, `cloudflare/cloudflare`)

## Prerequisites

### Required Tools

| Tool | Version | Installation |
|------|---------|-------------|
| Terraform | >= 1.0 | [terraform.io/downloads](https://developer.hashicorp.com/terraform/downloads) |
| Cloud CLI | Latest | See provider-specific instructions below |
| SSH Key | - | `ssh-keygen -t rsa -b 4096` |

```bash
# Verify Terraform installation
terraform version
# Expected: Terraform v1.x.x
```

### Cloud Provider CLIs

Install the CLI for your target cloud:

```bash
# AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# Google Cloud SDK
curl https://sdk.cloud.google.com | bash

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Alibaba Cloud CLI
pip install aliyuncli

# Oracle Cloud CLI
pip install oci-cli
```

### Authentication Setup

#### AWS
```bash
aws configure
# Enter: Access Key ID, Secret Access Key, Region, Output format
```

#### Google Cloud
```bash
gcloud auth application-default login
export TF_VAR_project_name="your-gcp-project-id"
```

#### Azure
```bash
az login
az account set --subscription "your-subscription-id"
```

#### Alibaba Cloud
```bash
export ALICLOUD_ACCESS_KEY="your-access-key"
export ALICLOUD_SECRET_KEY="your-secret-key"
export ALICLOUD_REGION="cn-beijing"
```

#### Oracle Cloud
```bash
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..."
export TF_VAR_user_ocid="ocid1.user.oc1..."
export TF_VAR_private_key_path="$HOME/.oci/oci_api_key.pem"
export TF_VAR_fingerprint="00:11:22:33:44:55:66:77..."
```

#### Cloudflare (DNS)
```bash
export TF_VAR_cloudflare_zone_id="your-zone-id"
export TF_VAR_cloudflare_api_token="your-api-token"
```

---

## Quick Start

### Option 1: Using the Deploy Script

```bash
cd terraform
chmod +x deploy.sh
./deploy.sh aws    # or: gcp, azure, alibaba, oracle
```

### Option 2: Manual Steps

```bash
# 1. Navigate to terraform directory
cd terraform

# 2. Initialize Terraform (downloads providers)
terraform init

# 3. Select your cloud provider
cp environments/aws.tfvars terraform.tfvars
# Edit terraform.tfvars with your values

# 4. Set your SSH public key
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"

# 5. Validate configuration
terraform validate

# 6. Preview changes
terraform plan

# 7. Deploy infrastructure
terraform apply

# 8. Get connection info
terraform output
```

---

## Directory Structure

```
terraform/
├── main.tf                     # Providers + module orchestration
├── variables.tf                # Root variable definitions
├── outputs.tf                  # Output values (IP, instance ID, etc.)
├── backend.tf.example          # Remote state backend template
├── terraform.tfvars.example    # Example variable values
├── deploy.sh                   # Automated deployment script
├── .gitignore                  # Excludes .terraform/, *.tfstate, etc.
│
├── modules/
│   ├── compute/                # VM provisioning (all clouds)
│   │   ├── main.tf            # EC2, Compute Engine, Azure VM, ECS, OCI
│   │   ├── variables.tf       # Instance config inputs
│   │   └── outputs.tf         # instance_id, public_ip, etc.
│   ├── networking/             # VPC/VNet + security groups
│   │   ├── main.tf            # VPC, subnets, firewall rules
│   │   ├── variables.tf       # CIDR, SSH allow lists
│   │   └── outputs.tf         # vpc_id, subnet_id, sg_id
│   ├── storage/                # Persistent volumes + backups
│   │   ├── main.tf            # EBS, PD, Managed Disk, etc.
│   │   ├── variables.tf       # Size, backup config
│   │   └── outputs.tf         # volume_id, mount_point
│   └── dns/                    # DNS record management
│       ├── main.tf            # Cloudflare, Route53, Cloud DNS, etc.
│       ├── variables.tf       # Domain, provider config
│       └── outputs.tf         # DNS record IDs
│
├── environments/               # Cloud-specific variable files
│   ├── aws.tfvars
│   ├── gcp.tfvars
│   ├── azure.tfvars
│   ├── alibaba.tfvars
│   └── oracle.tfvars
│
├── scripts/
│   └── user_data.sh           # VM bootstrap (Docker + Compose install)
│
└── README.md                   # This file
```

---

## Configuration

### Core Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `cloud_provider` | Target cloud: `aws`, `gcp`, `azure`, `alibaba`, `oracle` | — | Yes |
| `project_name` | Project identifier | `devops-academy` | No |
| `environment` | Environment name | `prod` | No |
| `region` | Cloud region | `us-central1` | Yes |
| `instance_type` | VM size: `small`, `medium`, `large` | `medium` | No |
| `ssh_public_key` | SSH public key for VM access | — | Yes |

### Networking Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `subnet_cidr` | Subnet CIDR | `10.0.1.0/24` |
| `allowed_ssh_cidr` | IPs allowed SSH | `["0.0.0.0/0"]` |
| `allowed_http_cidr` | IPs allowed HTTP | `["0.0.0.0/0"]` |
| `allowed_https_cidr` | IPs allowed HTTPS | `["0.0.0.0/0"]` |

### Storage & Backup Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `storage_size_gb` | Data volume size | `100` |
| `enable_backup` | Enable automated backups | `true` |
| `backup_retention_days` | Backup retention | `30` |

### DNS Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `domain_name` | Application domain | `devopsacademy.cloud-stacks.com` |
| `dns_provider` | DNS provider | `cloudflare` |
| `cloudflare_zone_id` | Cloudflare zone ID | — |
| `cloudflare_api_token` | Cloudflare API token | — |

### Oracle Cloud Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `tenancy_ocid` | OCI Tenancy OCID | — |

---

## Instance Type Mapping

The `instance_type` variable maps to cloud-specific sizes:

| Size | AWS | GCP | Azure | Alibaba | Oracle |
|------|-----|-----|-------|---------|--------|
| `small` | t3.small | e2-small | Standard_B1s | ecs.t5-lc1m2.small | VM.Standard.E2.1 |
| `medium` | t3.medium | e2-medium | Standard_B2s | ecs.t5-lc1m2.large | VM.Standard.E2.2 |
| `large` | t3.large | e2-standard-2 | Standard_B4ms | ecs.g6.large | VM.Standard.E2.4 |

---

## Cloud Provider Details

### AWS
| Component | Resource | Notes |
|-----------|----------|-------|
| Compute | `aws_instance` (EC2) | Ubuntu 24.04 AMI, gp3 root disk |
| Network | `aws_vpc` + `aws_subnet` | Public subnet with Internet Gateway |
| Security | `aws_security_group` | Ports 22, 80, 443 |
| Storage | `aws_ebs_volume` (gp3) | Attached via `aws_volume_attachment` |
| Backup | `aws_dlm_lifecycle_policy` | Daily snapshots, configurable retention |
| DNS | `aws_route53_record` | A + CNAME records |
| IP | `aws_eip` | Static Elastic IP |

### Google Cloud (GCP)
| Component | Resource | Notes |
|-----------|----------|-------|
| Compute | `google_compute_instance` | Ubuntu 24.04, startup-script |
| Network | `google_compute_network` + `subnetwork` | Auto-mode disabled |
| Security | `google_compute_firewall` | SSH, HTTP, HTTPS, internal rules |
| Storage | `google_compute_disk` | Attached via `google_compute_attached_disk` |
| Backup | `google_compute_snapshot` | Snapshot-based backups |
| DNS | `google_dns_record_set` | A + CNAME in managed zone |

### Azure
| Component | Resource | Notes |
|-----------|----------|-------|
| Compute | `azurerm_virtual_machine` | Ubuntu 22.04 LTS Gen2 |
| Network | `azurerm_virtual_network` + `subnet` | With NSG rules |
| Security | `azurerm_network_security_group` | Priority-based rules |
| Storage | `azurerm_managed_disk` | Standard_LRS |
| IP | `azurerm_public_ip` | Static Standard SKU |
| DNS | `azurerm_dns_a_record` | A + CNAME records |
| Group | `azurerm_resource_group` | All resources grouped |

### Alibaba Cloud
| Component | Resource | Notes |
|-----------|----------|-------|
| Compute | `alicloud_instance` (ECS) | Ubuntu 24.x, cloud_efficiency disk |
| Network | `alicloud_vpc` + `alicloud_vswitch` | Single availability zone |
| Security | `alicloud_security_group` | Ingress/egress rules |
| Storage | `alicloud_disk` | Attached via `alicloud_disk_attachment` |
| DNS | `alicloud_dns_record` | A + CNAME records |

### Oracle Cloud (OCI)
| Component | Resource | Notes |
|-----------|----------|-------|
| Compute | `oci_core_instance` | Ubuntu 24.04, flexible shapes |
| Network | `oci_core_vcn` + `oci_core_subnet` | With Internet Gateway |
| Security | `oci_core_security_list` | Ingress/egress rules |
| Storage | `oci_core_volume` | iSCSI attachment |
| Backup | `oci_core_volume_backup` | Native volume backups |
| DNS | `oci_dns_rrset` | A + CNAME record sets |

---

## Deployment Examples

### Deploy on AWS

```bash
cd terraform
terraform init

# Configure
cat > terraform.tfvars << 'EOF'
cloud_provider   = "aws"
region           = "us-east-1"
environment      = "prod"
instance_type    = "medium"
allowed_ssh_cidr = ["YOUR_IP/32"]
domain_name      = "devopsacademy.cloud-stacks.com"
dns_provider     = "cloudflare"
ssh_public_key   = "ssh-rsa AAAA... your-key"
EOF

# Deploy
terraform plan
terraform apply

# Connect
ssh ubuntu@$(terraform output -raw public_ip)
```

### Deploy on GCP

```bash
cd terraform
export TF_VAR_project_name="my-gcp-project"
terraform init

cat > terraform.tfvars << 'EOF'
cloud_provider   = "gcp"
region           = "us-central1"
instance_type    = "medium"
dns_provider     = "cloudflare"
ssh_public_key   = "ssh-rsa AAAA... your-key"
EOF

terraform apply
```

### Deploy on Azure

```bash
cd terraform
az login
terraform init

cat > terraform.tfvars << 'EOF'
cloud_provider   = "azure"
region           = "East US"
instance_type    = "medium"
dns_provider     = "cloudflare"
ssh_public_key   = "ssh-rsa AAAA... your-key"
EOF

terraform apply

# Connect
ssh azureuser@$(terraform output -raw public_ip)
```

### Switch Between Clouds

```bash
# Destroy current infrastructure
terraform destroy

# Switch to new cloud
cp environments/gcp.tfvars terraform.tfvars
terraform init -upgrade
terraform apply
```

---

## Common Operations

### Scale Instance

```bash
# Edit terraform.tfvars: change instance_type from "medium" to "large"
terraform plan   # Review changes
terraform apply  # Apply (may restart VM)
```

### Add Storage

```bash
# Edit terraform.tfvars: change storage_size_gb from 100 to 200
terraform plan
terraform apply
```

### Destroy Infrastructure

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy everything
terraform destroy

# Destroy specific module
terraform destroy -target=module.compute
```

### View Current State

```bash
# List all resources
terraform state list

# Show specific resource details
terraform state show module.compute.aws_instance.main

# Full state output
terraform show
```

---

## Security Best Practices

1. **Restrict SSH access** — Never use `0.0.0.0/0` in production:
   ```hcl
   allowed_ssh_cidr = ["203.0.113.10/32"]  # Your IP only
   ```

2. **Use environment variables for secrets**:
   ```bash
   export TF_VAR_cloudflare_api_token="your-token"
   export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"
   ```

3. **Enable remote state** for team environments:
   ```bash
   cp backend.tf.example backend.tf
   # Edit with your S3/GCS/Azure Blob details
   terraform init -migrate-state
   ```

4. **Review plans before apply**:
   ```bash
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

---

## Remote State Configuration

For production use, store Terraform state remotely. Copy `backend.tf.example`:

```hcl
# AWS S3 Backend
terraform {
  backend "s3" {
    bucket         = "devops-academy-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

---

## Troubleshooting

### "Provider not found" or "Missing required provider"
```bash
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### "Invalid credentials"
- AWS: Verify `~/.aws/credentials` or `AWS_ACCESS_KEY_ID` env var
- GCP: Run `gcloud auth application-default login`
- Azure: Run `az login`
- Alibaba: Check `ALICLOUD_ACCESS_KEY` and `ALICLOUD_SECRET_KEY`
- Oracle: Verify `TF_VAR_tenancy_ocid` and API key configuration

### "Resource already exists"
```bash
# Import the existing resource into state
terraform import module.compute.aws_instance.main i-1234567890abcdef0
```

### "Timeout waiting for SSH"
- Check security group allows port 22 from your IP
- Verify `enable_public_ip = true`
- Confirm your IP is in `allowed_ssh_cidr`

### State Lock Issues
```bash
terraform force-unlock <LOCK_ID>
```

---

## Commands Reference

```bash
terraform init              # Download providers and modules
terraform validate          # Check configuration syntax
terraform fmt -recursive    # Format all .tf files
terraform plan              # Preview changes
terraform apply             # Apply changes
terraform destroy           # Remove all resources
terraform output            # Show output values
terraform state list        # List managed resources
terraform state show <res>  # Inspect a resource
terraform import <res> <id> # Import existing resource
terraform refresh           # Sync state with cloud
```

---

## CI/CD Integration

### GitHub Actions

```yaml
name: Terraform Deploy
on:
  push:
    branches: [main]
    paths: ['terraform/**']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      
      - name: Terraform Init
        run: terraform init
        working-directory: terraform
        
      - name: Terraform Validate
        run: terraform validate
        working-directory: terraform
        
      - name: Terraform Plan
        run: terraform plan -out=tfplan
        working-directory: terraform
        env:
          TF_VAR_ssh_public_key: ${{ secrets.SSH_PUBLIC_KEY }}
          TF_VAR_cloudflare_api_token: ${{ secrets.CF_API_TOKEN }}
          
      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
        working-directory: terraform
```

---

## Provider Versions

| Provider | Source | Version |
|----------|--------|---------|
| AWS | `hashicorp/aws` | ~> 5.0 |
| Google Cloud | `hashicorp/google` | ~> 5.0 |
| Azure | `hashicorp/azurerm` | ~> 3.0 |
| Alibaba Cloud | `aliyun/alicloud` | ~> 1.0 |
| Oracle Cloud | `oracle/oci` | ~> 5.0 |
| Cloudflare | `cloudflare/cloudflare` | ~> 4.0 |

---

## Additional Resources

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest)
- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Alibaba Provider](https://registry.terraform.io/providers/aliyun/alicloud/latest)
- [Oracle Provider](https://registry.terraform.io/providers/oracle/oci/latest)
- [Cloudflare Provider](https://registry.terraform.io/providers/cloudflare/cloudflare/latest)

---

**Last Updated**: June 2026  
**Maintained by**: DevOps Academy Team
