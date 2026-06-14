# Terraform Multi-Cloud Infrastructure - Complete Guide

## 🎯 Overview

A **production-ready, multi-cloud Terraform Infrastructure as Code (IaC)** solution has been created to deploy the DevOps Academy infrastructure across **5 major cloud providers**:
- ✅ **AWS** (Amazon Web Services)
- ✅ **GCP** (Google Cloud Platform)
- ✅ **Azure** (Microsoft Azure)
- ✅ **Alibaba Cloud** (Aliyun)
- ✅ **Oracle Cloud Infrastructure** (OCI)

Simply **change one variable** (`cloud_provider`) to switch between clouds!

---

## 📂 Project Structure

```
terraform/
├── main.tf                          # Main configuration, provider setup, module calls
├── variables.tf                     # Global variable definitions (150+ variables)
├── outputs.tf                       # Output definitions (instance IPs, DNS, etc.)
├── terraform.tfvars.example         # Configuration template
├── backend.tf.example               # Remote state backend configuration
├── deploy.sh                        # Deployment automation script
├── README.md                        # Comprehensive documentation
├── .gitignore                       # Git ignore rules
│
├── modules/                         # Reusable infrastructure modules
│   ├── compute/                     # VM/Instance provisioning
│   │   ├── main.tf                  # AWS EC2, GCP Compute Engine, Azure VM, etc.
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── networking/                  # VPC, Subnets, Security Groups
│   │   ├── main.tf                  # AWS VPC, GCP Network, Azure VNet, etc.
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── storage/                     # Persistent volumes & backups
│   │   ├── main.tf                  # AWS EBS, GCP Persistent Disks, Azure Managed Disks, etc.
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── dns/                         # DNS record management
│       ├── main.tf                  # Route53, Cloud DNS, Azure DNS, etc.
│       ├── variables.tf
│       └── outputs.tf
│
├── scripts/                         # Deployment scripts
│   └── user_data.sh                 # Docker & Docker Compose installation
│
└── environments/                    # Cloud-specific configurations
    ├── aws.tfvars                   # AWS pre-configured values
    ├── gcp.tfvars                   # GCP pre-configured values
    ├── azure.tfvars                 # Azure pre-configured values
    ├── alibaba.tfvars               # Alibaba Cloud pre-configured values
    └── oracle.tfvars                # Oracle Cloud pre-configured values
```

---

## 🚀 Quick Start Guide

### Option 1: Using the Deployment Script (Easiest)

```bash
cd terraform
chmod +x deploy.sh
./deploy.sh aws  # or: gcp, azure, alibaba, oracle
```

The script will:
1. ✅ Check prerequisites (Terraform, cloud CLI, credentials)
2. ✅ Initialize Terraform
3. ✅ Prepare configuration from environment files
4. ✅ Show infrastructure plan
5. ✅ Deploy infrastructure
6. ✅ Display outputs (IP addresses, SSH commands, etc.)

### Option 2: Manual Deployment

```bash
# 1. Initialize Terraform
cd terraform
terraform init

# 2. Prepare configuration
cp environments/aws.tfvars terraform.tfvars

# 3. Edit configuration (customize region, allowed IPs, etc.)
vim terraform.tfvars

# 4. Review plan
terraform plan

# 5. Deploy
terraform apply

# 6. Get outputs
terraform output -json
```

---

## 🔧 Configuration: Key Variables

### Primary Configuration Variable

The main switch to choose cloud provider:

```hcl
# Change this to switch between clouds
cloud_provider = "aws"  # Options: aws, gcp, azure, alibaba, oracle
```

### Essential Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `region` | Cloud region | `us-east-1` (AWS), `us-central1` (GCP) |
| `instance_type` | VM size | `small`, `medium`, `large` |
| `vpc_cidr` | Network CIDR | `10.0.0.0/16` |
| `domain_name` | Your domain | `devopsacademy.cloud-stacks.com` |
| `allowed_ssh_cidr` | SSH access IPs | `["YOUR_IP/32"]` |
| `enable_backup` | Enable backups | `true` |
| `storage_size_gb` | Storage volume size | `100` |

### Quick Configuration Template

```hcl
# terraform.tfvars
cloud_provider = "aws"
environment    = "prod"
region         = "us-east-1"
instance_type  = "medium"

# SECURITY: Restrict SSH to your IP
allowed_ssh_cidr = ["203.0.113.42/32"]  # Change to your IP

# DNS
domain_name = "devopsacademy.cloud-stacks.com"
dns_provider = "route53"

# Storage
storage_size_gb = 100
enable_backup   = true
```

---

## 🏗️ Infrastructure Components Created

### 1. **Networking**
- ✅ Virtual Private Cloud (VPC/VNet)
- ✅ Subnets with configurable CIDR
- ✅ Security Groups / Firewalls
- ✅ Internet Gateways / NAT
- ✅ Route Tables / Network policies

### 2. **Compute**
- ✅ Linux VM (Ubuntu 24.04 LTS)
- ✅ Pre-configured instance types (small/medium/large)
- ✅ Automatic Docker & Docker Compose installation
- ✅ Public/Private IP configuration
- ✅ Monitoring enabled

### 3. **Storage**
- ✅ Persistent block storage (50+ GB)
- ✅ Automatic mounting at /mnt/data
- ✅ Automated backups (daily snapshots)
- ✅ Configurable retention (30 days default)

### 4. **DNS Management**
- ✅ DNS A records for domain
- ✅ CNAME records for www subdomain
- ✅ Support for multiple DNS providers

### 5. **Security Features**
- ✅ Encrypted storage volumes
- ✅ Security group rules for SSH/HTTP/HTTPS
- ✅ SSH key-based authentication
- ✅ Network isolation (private subnets available)

---

## ☁️ Cloud Provider Specifics

### AWS Deployment

```bash
# Prerequisites
aws configure  # Configure AWS CLI

# Deploy
cp environments/aws.tfvars terraform.tfvars
terraform plan
terraform apply

# Instance types: t3.small, t3.medium, t3.large
# Storage: EBS gp3 with automatic DLM snapshots
# DNS: Route53
```

**Features:**
- EBS volumes with automatic Daily snapshots
- AWS Data Lifecycle Manager (DLM) for backup retention
- EC2 detailed monitoring
- Elastic IP for static public IP

### GCP Deployment

```bash
# Prerequisites
gcloud auth login
export GOOGLE_PROJECT_ID="my-project"

# Deploy
cp environments/gcp.tfvars terraform.tfvars
terraform plan
terraform apply

# Instance types: e2-small, e2-medium, e2-large
# Storage: Persistent Disks with snapshots
# DNS: Cloud DNS
```

**Features:**
- Persistent disk snapshots
- Automatic image lookups
- Firewall rules (more flexible than security groups)
- Cloud DNS integration

### Azure Deployment

```bash
# Prerequisites
az login

# Deploy
cp environments/azure.tfvars terraform.tfvars
terraform plan
terraform apply

# Instance types: Standard_B1s, Standard_B2s, Standard_B2ms
# Storage: Managed Disks
# DNS: Azure DNS
```

**Features:**
- Managed disks (no separate storage account needed)
- Network Security Groups (NSGs)
- Public IP allocation
- Azure DNS zone management

### Alibaba Cloud Deployment

```bash
# Prerequisites
aliyun configure set

# Deploy
cp environments/alibaba.tfvars terraform.tfvars
terraform plan
terraform apply

# Instance types: ecs.t6-c1m1.small, etc.
# Storage: Cloud Disks (cloud_efficiency)
# DNS: Alibaba Cloud DNS
```

**Features:**
- Aliyun ECS instances
- VSwitches (Alibaba's subnet concept)
- Security group rules with IP protocol numbers
- Snapshots for backup

### Oracle Cloud Deployment

```bash
# Prerequisites
export TF_VAR_tenancy_ocid="ocid1.tenancy..."
export TF_VAR_user_ocid="ocid1.user..."
export TF_VAR_private_key_path="$HOME/.oci/oci_api_key.pem"

# Deploy
cp environments/oracle.tfvars terraform.tfvars
terraform plan
terraform apply

# Instance types: VM.Standard3.Flex
# Storage: Block Storage
# DNS: Oracle DNS
```

**Features:**
- VCN (Virtual Cloud Network)
- Always Free tier eligible
- Security lists (firewall rules)
- Volume backups

---

## 🎯 Deployment Examples

### Example 1: Deploy on AWS (1 minute)

```bash
cd terraform
terraform init
cp environments/aws.tfvars terraform.tfvars

# Edit to customize
sed -i 's/allowed_ssh_cidr.*/allowed_ssh_cidr = ["203.0.113.42\/32"]/g' terraform.tfvars

terraform plan
terraform apply -auto-approve

# Get IP
terraform output -raw public_ip
# Result: 54.123.45.67
```

### Example 2: Deploy on GCP with Custom Region

```bash
cd terraform
terraform init
cp environments/gcp.tfvars terraform.tfvars

cat >> terraform.tfvars << EOF
region = "europe-west1"
domain_name = "my-app.example.com"
dns_provider = "gcloud"
EOF

terraform apply
```

### Example 3: Deploy on Azure

```bash
cd terraform
terraform init

# Use Azure DNS
cat > terraform.tfvars << EOF
cloud_provider = "azure"
region = "West Europe"
domain_name = "devopsacademy.cloud-stacks.com"
dns_provider = "azure-dns"
allowed_ssh_cidr = ["YOUR_IP/32"]
EOF

terraform apply
```

### Example 4: Switch from AWS to GCP

```bash
cd terraform

# Backup current state
cp terraform.tfstate terraform.tfstate.aws.backup

# Switch to GCP
cp environments/gcp.tfvars terraform.tfvars

# Re-initialize (creates new state)
rm -rf .terraform terraform.lock.hcl
terraform init

# Deploy on GCP
terraform apply
```

---

## 📊 Outputs Available After Deployment

After `terraform apply`, these outputs are available:

```bash
terraform output -json
```

**Output Example:**
```json
{
  "deployment_info": {
    "cloud_provider": "aws",
    "domain_name": "devopsacademy.cloud-stacks.com",
    "instance_ip": "54.123.45.67",
    "region": "us-east-1",
    "status": "Deployed successfully"
  },
  "instance_id": "i-0123456789abcdef0",
  "instance_username": "ubuntu",
  "private_ip": "10.0.1.25",
  "public_ip": "54.123.45.67",
  "security_group_id": "sg-0123456789abcdef0",
  "ssh_connection_command": "ssh -i <your-key> ubuntu@54.123.45.67",
  "storage_mount_point": "/dev/sdf",
  "storage_volume_id": "vol-0123456789abcdef0",
  "subnet_id": "subnet-0123456789abcdef0",
  "vpc_id": "vpc-0123456789abcdef0"
}
```

**Connect to Instance:**
```bash
ssh -i ~/.ssh/your-key.pem ubuntu@54.123.45.67
```

---

## 🔐 Security Considerations

### 1. Restrict SSH Access
```hcl
# ❌ DON'T DO THIS
allowed_ssh_cidr = ["0.0.0.0/0"]  # Open to everyone!

# ✅ DO THIS
allowed_ssh_cidr = ["203.0.113.42/32"]  # Your IP only
```

### 2. Use Sensitive Variables
```bash
# Store sensitive data in environment variables, not in code
export TF_VAR_cloudflare_api_token="sk_live_xxx"
```

### 3. Remote State for Production
```hcl
# backend.tf - Use S3, GCS, or Azure Storage
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### 4. Encrypt Everything
- ✅ All storage volumes are encrypted
- ✅ All providers use encryption by default
- ✅ Enable state file encryption in backend

---

## 🔄 Common Operations

### Scale Up Instance
```bash
# Edit terraform.tfvars
sed -i 's/instance_type = "medium"/instance_type = "large"/g' terraform.tfvars

# Apply changes
terraform plan
terraform apply
```

### Add More Storage
```bash
# Edit terraform.tfvars
sed -i 's/storage_size_gb = 100/storage_size_gb = 200/g' terraform.tfvars

terraform plan
terraform apply
```

### Update Domain Name
```bash
# Edit terraform.tfvars
sed -i 's/domain_name.*/domain_name = "new-domain.com"/g' terraform.tfvars

terraform plan
terraform apply
```

### Destroy Infrastructure
```bash
# Review what will be deleted
terraform plan -destroy

# Delete all resources
terraform destroy

# Verify deletion
terraform show  # Should be empty
```

---

## 📚 Advanced Features

### 1. Remote State Management

Store state remotely for team collaboration:

```bash
# Uncomment backend.tf.example
mv backend.tf.example backend.tf

# Configure your backend (S3, GCS, Azure, etc.)
vim backend.tf

# Migrate state
terraform init  # Terraform will ask to migrate
```

### 2. Terraform Workspaces

Deploy multiple environments:

```bash
# Create separate workspaces
terraform workspace new prod
terraform workspace new staging
terraform workspace new dev

# Switch between environments
terraform workspace select prod
terraform apply
```

### 3. Custom Variables

Override any variable:

```bash
# Via command line
terraform plan -var="instance_type=large" -var="region=eu-west-1"

# Via environment variables
export TF_VAR_instance_type="large"
terraform plan

# Via .tfvars files (recommended)
terraform plan -var-file="prod.tfvars"
```

### 4. Module Customization

Extend modules for custom resources:

```hcl
# In main.tf, add custom resources
resource "aws_s3_bucket" "app_data" {
  count  = local.cloud_provider_lower == "aws" ? 1 : 0
  bucket = "${var.project_name}-data"
}
```

---

## 🐛 Troubleshooting

### "terraform: command not found"
```bash
# Install Terraform
# macOS: brew install terraform
# Windows: choco install terraform
# Linux: Download from https://www.terraform.io/downloads
```

### "Error: Invalid provider configuration"
```bash
# Verify credentials are set
aws configure          # For AWS
gcloud auth login      # For GCP
az login              # For Azure

# Re-initialize
terraform init
```

### "Error: Resource already exists"
```bash
# Import existing resource
terraform import module.compute.aws_instance.main i-xxx

# Or destroy and recreate
terraform taint module.compute.aws_instance.main
terraform apply
```

### "timeout: timed out waiting for ..."
```bash
# Increase timeout in variables.tf
# Check security group allows inbound traffic
# Verify SSH key is correct

# Retry deployment
terraform apply -destroy
terraform apply
```

---

## 📋 File Descriptions

| File | Purpose |
|------|---------|
| `main.tf` | Main configuration - providers, modules |
| `variables.tf` | 150+ variable definitions |
| `outputs.tf` | Instance IPs, DNS, SSH commands, etc. |
| `terraform.tfvars.example` | Configuration template (copy and customize) |
| `backend.tf.example` | Remote state setup (for production) |
| `deploy.sh` | Automated deployment script |
| `README.md` | Complete documentation |
| `.gitignore` | Exclude state files from git |
| `modules/compute/` | VM/Instance provisioning (all clouds) |
| `modules/networking/` | VPC, subnets, security groups (all clouds) |
| `modules/storage/` | Persistent volumes, backups (all clouds) |
| `modules/dns/` | DNS record management (all clouds) |
| `scripts/user_data.sh` | Docker installation script |
| `environments/*.tfvars` | Pre-configured values per cloud |

---

## ✅ Verification Checklist

After deployment, verify everything works:

```bash
# 1. Check Terraform state
terraform show

# 2. Check outputs
terraform output -json | jq '.'

# 3. SSH into instance
ssh -i ~/.ssh/key.pem ubuntu@$(terraform output -raw public_ip)

# 4. Verify Docker is installed
docker --version
docker-compose --version

# 5. Check storage mount
df -h | grep /mnt/data

# 6. Verify DNS (if configured)
nslookup devopsacademy.cloud-stacks.com
```

---

## 📖 Next Steps

1. **Initialize Terraform**: `terraform init`
2. **Choose Cloud**: Copy `environments/{cloud}.tfvars` to `terraform.tfvars`
3. **Customize**: Edit `terraform.tfvars` with your settings
4. **Deploy**: `terraform apply`
5. **Verify**: `terraform output && ssh to instance`
6. **Deploy Docker Stack**: `docker-compose up -d` (see DEPLOYMENT.md)

---

## 📞 Support

- 📖 Full Terraform README: `terraform/README.md`
- 🏗️ Architecture Guide: `ARCHITECTURE.md`
- 🚀 Deployment Guide: `DEPLOYMENT.md`
- 💬 GitHub Issues: https://github.com/Maged2344/DevopsAcademy/issues

---

## License

Private — DevOps Academy Egypt © 2024-2026

**Status**: ✅ Production Ready | Multi-Cloud | Fully Automated
