# Terraform Infrastructure as Code - DevOps Academy

Multi-cloud infrastructure provisioning for DevOps Academy using HashiCorp Terraform. Deploy the complete stack across **AWS**, **GCP**, **Azure**, **Alibaba Cloud**, or **Oracle Cloud** with a single variable change.

## 🎯 Features

- **Multi-Cloud Support**: AWS, GCP, Azure, Alibaba Cloud, Oracle Cloud
- **Infrastructure Components**:
  - Virtual Machines (EC2, Compute Engine, VMs, ECS, OCI Compute)
  - Virtual Networks (VPC/VNet with subnets and security groups)
  - Persistent Storage (EBS, Persistent Disks, Managed Disks, Disks, Block Storage)
  - DNS Management (Route53, Cloud DNS, Azure DNS, Alibaba DNS, Oracle DNS)
  - Automated Backups (DLM, Snapshots, etc.)
- **Docker-Ready**: Automatic installation of Docker and Docker Compose
- **Modular Design**: Reusable modules for compute, networking, storage, and DNS
- **Environment Management**: Pre-configured environments for each cloud provider

## 📋 Prerequisites

### Required Tools

1. **Terraform** (v1.0+)
   ```bash
   # macOS (Homebrew)
   brew install terraform
   
   # Windows (Chocolatey)
   choco install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.x.x/terraform_1.x.x_linux_amd64.zip
   unzip terraform_*_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

2. **Cloud Provider CLI** (one or more):
   - AWS CLI v2
   - Google Cloud SDK (gcloud)
   - Azure CLI (az)
   - Alibaba Cloud CLI (aliyun)
   - Oracle Cloud CLI (oci)

### Required Credentials

Set up credentials for your target cloud provider:

#### AWS
```bash
aws configure
# Enter: Access Key ID, Secret Access Key, Default region, Output format
```

#### Google Cloud
```bash
gcloud auth application-default login
export GOOGLE_PROJECT_ID="your-project-id"
```

#### Azure
```bash
az login
az account set --subscription "your-subscription-id"
```

#### Alibaba Cloud
```bash
aliyun configure set
# Enter: Access Key ID, Secret Access Key, Region
```

#### Oracle Cloud
```bash
# Set environment variables
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..."
export TF_VAR_user_ocid="ocid1.user.oc1..."
export TF_VAR_private_key_path="$HOME/.oci/oci_api_key.pem"
export TF_VAR_fingerprint="00:11:22:33:44:55:66:77..."
```

#### Cloudflare (for DNS)
```bash
# Get your API token from https://dash.cloudflare.com/profile/api-tokens
export TF_VAR_cloudflare_zone_id="your-zone-id"
export TF_VAR_cloudflare_api_token="your-api-token"
```

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/Maged2344/DevopsAcademy.git
cd DevopsAcademy/terraform
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Select Your Cloud Provider

Copy the appropriate environment file and customize it:

```bash
# For AWS
cp environments/aws.tfvars terraform.tfvars
# Edit terraform.tfvars and set your values

# For GCP
cp environments/gcp.tfvars terraform.tfvars

# For Azure
cp environments/azure.tfvars terraform.tfvars

# For Alibaba Cloud
cp environments/alibaba.tfvars terraform.tfvars

# For Oracle Cloud
cp environments/oracle.tfvars terraform.tfvars
```

### 4. Review the Plan
```bash
terraform plan
```

### 5. Apply the Configuration
```bash
terraform apply
```

### 6. Get Output Values
```bash
terraform output -json
```

## 📁 Directory Structure

```
terraform/
├── main.tf                 # Main configuration (providers, modules)
├── variables.tf            # Global variable definitions
├── outputs.tf              # Output definitions
├── terraform.tfvars        # Terraform values (create from environments/)
├── .gitignore              # Git ignore rules
│
├── modules/                # Reusable modules
│   ├── compute/            # VM/Instance configuration
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── networking/         # VPC, Subnets, Security Groups
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── storage/            # Persistent volumes & backups
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── dns/                # DNS record management
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── scripts/                # Deployment scripts
│   └── user_data.sh        # Docker & Docker Compose installation
│
├── environments/           # Cloud provider configurations
│   ├── aws.tfvars          # AWS settings
│   ├── gcp.tfvars          # GCP settings
│   ├── azure.tfvars        # Azure settings
│   ├── alibaba.tfvars      # Alibaba Cloud settings
│   └── oracle.tfvars       # Oracle Cloud settings
│
└── README.md               # This file
```

## 🔧 Configuration Variables

### Global Variables (variables.tf)

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
| `cloud_provider` | Target cloud (aws, gcp, azure, alibaba, oracle) | - | string |
| `project_name` | Project name | devops-academy | string |
| `environment` | Environment name | prod | string |
| `region` | Cloud region | us-central1 | string |
| `instance_type` | VM size (small, medium, large) | medium | string |
| `vpc_cidr` | VPC CIDR block | 10.0.0.0/16 | string |
| `subnet_cidr` | Subnet CIDR block | 10.0.1.0/24 | string |
| `storage_size_gb` | Storage volume size | 100 | number |
| `enable_backup` | Enable automated backups | true | bool |
| `backup_retention_days` | Backup retention period | 30 | number |
| `domain_name` | Domain for the app | devopsacademy.cloud-stacks.com | string |

### Environment-Specific Variables

Each `environments/*.tfvars` file contains pre-configured values for its cloud provider. Edit these files to customize:

```hcl
cloud_provider = "aws"              # Change to your cloud
region = "us-east-1"               # Change to your region
allowed_ssh_cidr = ["YOUR_IP/32"]   # Restrict SSH access
```

## 📊 Supported Cloud Providers

### AWS (aws)
- Compute: EC2 t3 instances
- Network: VPC, Subnets, Security Groups, Internet Gateway
- Storage: EBS volumes with gp3 optimization
- Backups: AWS DLM snapshots
- DNS: Route53

### Google Cloud (gcp)
- Compute: Compute Engine e2 instances
- Network: VPC, Subnets, Firewall rules
- Storage: Persistent Disks
- Backups: GCP Snapshots
- DNS: Google Cloud DNS

### Azure (azure)
- Compute: Virtual Machines
- Network: Virtual Networks, Subnets, NSGs
- Storage: Managed Disks
- Backups: Azure Backup (manual)
- DNS: Azure DNS

### Alibaba Cloud (alibaba)
- Compute: ECS instances
- Network: VPC, VSwitches, Security Groups
- Storage: Cloud Disks
- Backups: Snapshots
- DNS: Alibaba DNS

### Oracle Cloud (oracle)
- Compute: OCI Compute instances
- Network: VCN, Subnets, Security Lists
- Storage: Block Storage
- Backups: Volume Backups
- DNS: Oracle DNS

## 🔐 Security Best Practices

1. **Restrict SSH Access**
   ```hcl
   allowed_ssh_cidr = ["YOUR_IP/32"]  # Use your IP, not 0.0.0.0/0
   ```

2. **Use Sensitive Variables**
   ```bash
   export TF_VAR_cloudflare_api_token="your-token"
   ```

3. **Store State Remotely** (for production)
   ```hcl
   terraform {
     backend "s3" {
       bucket = "your-terraform-state"
       key    = "devops-academy/prod/terraform.tfstate"
       region = "us-east-1"
     }
   }
   ```

4. **Enable Encryption**
   - AWS: EBS encryption enabled by default
   - GCP: Persistent disks use Google-managed keys
   - Azure: Managed disks use platform-managed keys

## 📝 Common Operations

### Deploy to AWS
```bash
cp environments/aws.tfvars terraform.tfvars
# Edit terraform.tfvars
terraform init
terraform plan
terraform apply
```

### Switch Clouds (e.g., AWS to GCP)
```bash
# Backup current state (optional)
cp terraform.tfstate terraform.tfstate.aws.backup

# Switch configuration
cp environments/gcp.tfvars terraform.tfvars

# Re-initialize
rm -rf .terraform
terraform init

# Plan and apply
terraform plan
terraform apply
```

### Destroy Infrastructure
```bash
# Review what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# Destroy specific resource
terraform destroy -target=module.compute.aws_instance.main
```

### Update Infrastructure
```bash
# Edit terraform.tfvars
vim terraform.tfvars

# Plan changes
terraform plan

# Apply changes
terraform apply
```

### Scale Up/Down
```bash
# Edit instance_type in terraform.tfvars
# Change from "medium" to "large" or "small"
terraform plan
terraform apply
```

## 🎯 Example: Deploy on AWS

```bash
# 1. Initialize
cd DevopsAcademy/terraform
terraform init

# 2. Configure for AWS
cp environments/aws.tfvars terraform.tfvars
cat > terraform.tfvars << EOF
cloud_provider = "aws"
environment = "prod"
region = "us-east-1"
instance_type = "medium"
allowed_ssh_cidr = ["203.0.113.45/32"]  # Your IP
domain_name = "devopsacademy.cloud-stacks.com"
dns_provider = "route53"
EOF

# 3. Verify configuration
terraform validate
terraform plan

# 4. Deploy
terraform apply -auto-approve

# 5. Get outputs
terraform output -json | jq '.'

# 6. SSH into instance
ssh -i ~/.ssh/your-key.pem ubuntu@$(terraform output -raw public_ip)
```

## 🎯 Example: Deploy on GCP

```bash
# 1. Authenticate with GCP
gcloud auth login
export GOOGLE_PROJECT_ID="my-project-id"

# 2. Configure for GCP
terraform init
cp environments/gcp.tfvars terraform.tfvars

# 3. Edit terraform.tfvars
cat > terraform.tfvars << EOF
cloud_provider = "gcp"
region = "us-central1"
instance_type = "medium"
EOF

# 4. Deploy
terraform apply

# 5. SSH into instance
gcloud compute ssh $(terraform output -raw instance_name) --zone=us-central1-a
```

## 🐛 Troubleshooting

### "Provider not found" Error
```bash
# Reinitialize Terraform
rm -rf .terraform terraform.lock.hcl
terraform init
```

### "Invalid credentials" Error
- Verify your cloud provider credentials are set correctly
- For AWS: Check `~/.aws/credentials`
- For GCP: Run `gcloud auth application-default login`
- For Azure: Run `az login`

### "Resource already exists" Error
```bash
# Import existing resource into state
terraform import module.compute.aws_instance.main i-1234567890abcdef0

# Or destroy and recreate
terraform destroy -target=module.compute.aws_instance.main
terraform apply
```

### "Timeout waiting for SSH"
- Verify security group/firewall allows inbound SSH (port 22)
- Check that public IP was assigned
- Verify your IP is in `allowed_ssh_cidr`

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Terraform Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Terraform Alibaba Provider Documentation](https://registry.terraform.io/providers/aliyun/alicloud/latest)
- [Terraform Oracle Provider Documentation](https://registry.terraform.io/providers/oracle/oci/latest)

## 📋 Terraform Commands Reference

```bash
# Initialize working directory
terraform init

# Validate configuration files
terraform validate

# Format code
terraform fmt -recursive

# Show planned changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy

# Show current state
terraform show

# List resources
terraform state list

# Inspect resource
terraform state show module.compute.aws_instance.main

# Output variables
terraform output
terraform output public_ip
terraform output -json

# Refresh state
terraform refresh

# Taint resource (force recreation)
terraform taint module.compute.aws_instance.main

# Import existing resource
terraform import module.compute.aws_instance.main i-1234567890abcdef0
```

## 🔄 CI/CD Integration

### GitHub Actions Example
```yaml
name: Terraform Deploy
on:
  push:
    branches: [main]
    paths: [terraform/**]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: hashicorp/setup-terraform@v2
      - name: Terraform Init
        run: terraform init
        working-directory: terraform
      - name: Terraform Plan
        run: terraform plan -out=tfplan
        working-directory: terraform
      - name: Terraform Apply
        run: terraform apply tfplan
        working-directory: terraform
```

## 📄 License

Private — DevOps Academy Egypt © 2024-2026

## 🤝 Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on contributing to this project.

## ❓ Support

- 📖 [DEPLOYMENT.md](../DEPLOYMENT.md) - Full deployment guide
- 🏗️ [ARCHITECTURE.md](../ARCHITECTURE.md) - Architecture documentation
- 💬 [GitHub Issues](https://github.com/Maged2344/DevopsAcademy/issues)

---

**Last Updated**: June 2026
**Maintained by**: DevOps Academy Team
