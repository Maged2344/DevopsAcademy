################################################################################
# Global Variables
################################################################################

variable "cloud_provider" {
  description = "Cloud provider to deploy on (aws, gcp, azure, alibaba, oracle)"
  type        = string
  validation {
    condition     = contains(["aws", "gcp", "azure", "alibaba", "oracle"], lower(var.cloud_provider))
    error_message = "cloud_provider must be one of: aws, gcp, azure, alibaba, oracle"
  }
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "devops-academy"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "region" {
  description = "Region/Location to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "instance_type" {
  description = "Instance type/size for compute"
  type        = string
  default     = "medium"
}

################################################################################
# Compute Instance Variables
################################################################################

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
  default     = "devops-academy-server"
}

variable "os_image" {
  description = "OS image for the instance"
  type        = string
  default     = "ubuntu-2404-lts"
}

variable "disk_size_gb" {
  description = "Root disk size in GB"
  type        = number
  default     = 50
}

variable "enable_public_ip" {
  description = "Enable public IP address"
  type        = bool
  default     = true
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  default     = ""
}

################################################################################
# Networking Variables
################################################################################

variable "vpc_cidr" {
  description = "VPC/Network CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Restrict this in production
}

variable "allowed_http_cidr" {
  description = "CIDR blocks allowed for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_https_cidr" {
  description = "CIDR blocks allowed for HTTPS access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

################################################################################
# Oracle Cloud Variables
################################################################################

variable "tenancy_ocid" {
  description = "Oracle Cloud Tenancy OCID"
  type        = string
  default     = ""
}

################################################################################
# DNS Variables
################################################################################

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "devopsacademy.cloud-stacks.com"
}

variable "dns_provider" {
  description = "DNS provider (cloudflare, route53, gcloud, azure-dns, alibaba-dns, oracle-dns)"
  type        = string
  default     = "cloudflare"
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  default     = ""
  sensitive   = true
}

################################################################################
# SSL/TLS Variables
################################################################################

variable "enable_ssl" {
  description = "Enable SSL/TLS with Let's Encrypt"
  type        = bool
  default     = true
}

variable "letsencrypt_email" {
  description = "Email for Let's Encrypt certificate"
  type        = string
  default     = "admin@devopsacademy.cloud-stacks.com"
}

################################################################################
# Container & Application Variables
################################################################################

variable "docker_registry" {
  description = "Docker registry URL"
  type        = string
  default     = "docker.io"
}

variable "backend_image" {
  description = "Backend Docker image"
  type        = string
  default     = "node:20-alpine"
}

variable "mongo_image" {
  description = "MongoDB Docker image"
  type        = string
  default     = "mongo:7"
}

variable "nginx_image" {
  description = "Nginx Docker image"
  type        = string
  default     = "nginx:alpine"
}

variable "prometheus_image" {
  description = "Prometheus Docker image"
  type        = string
  default     = "prom/prometheus:latest"
}

variable "grafana_image" {
  description = "Grafana Docker image"
  type        = string
  default     = "grafana/grafana:latest"
}

################################################################################
# Storage Variables
################################################################################

variable "storage_size_gb" {
  description = "Storage size for persistent volumes in GB"
  type        = number
  default     = 100
}

variable "enable_backup" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

################################################################################
# Tags/Labels
################################################################################

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    project     = "devops-academy"
    managed_by  = "terraform"
    environment = "production"
  }
}

variable "labels" {
  description = "Common labels for all resources"
  type        = map(string)
  default = {
    project    = "devops-academy"
    managed_by = "terraform"
  }
}
