################################################################################
# Provider Configuration
################################################################################

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.0"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

################################################################################
# AWS Provider
################################################################################

provider "aws" {
  count  = lower(var.cloud_provider) == "aws" ? 1 : 0
  region = var.region
  
  default_tags {
    tags = var.tags
  }
}

################################################################################
# Google Cloud Provider
################################################################################

provider "google" {
  count   = lower(var.cloud_provider) == "gcp" ? 1 : 0
  region  = var.region
  project = var.project_name # Must be set via TF_VAR_project_name or terraform.tfvars
}

################################################################################
# Azure Provider
################################################################################

provider "azurerm" {
  count = lower(var.cloud_provider) == "azure" ? 1 : 0
  
  features {
    virtual_machine {
      delete_os_disk_on_deletion            = true
      graceful_shutdown                     = false
      skip_shutdown_and_force_delete        = false
    }
  }
  
  skip_provider_registration = false
}

################################################################################
# Alibaba Cloud Provider
################################################################################

provider "alicloud" {
  count  = lower(var.cloud_provider) == "alibaba" ? 1 : 0
  region = var.region
}

################################################################################
# Oracle Cloud Provider
################################################################################

provider "oci" {
  count = lower(var.cloud_provider) == "oracle" ? 1 : 0
  
  region = var.region
  # tenancy_ocid, user_ocid, private_key_path, fingerprint should be set via
  # environment variables: TF_VAR_tenancy_ocid, etc.
}

################################################################################
# Cloudflare Provider
################################################################################

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

################################################################################
# Local Variables
################################################################################

locals {
  cloud_provider_lower = lower(var.cloud_provider)
  
  common_labels = merge(
    var.labels,
    {
      cloud_provider = local.cloud_provider_lower
      environment    = var.environment
    }
  )
}

################################################################################
# Networking Module
################################################################################

module "networking" {
  source = "./modules/networking"
  
  cloud_provider        = local.cloud_provider_lower
  project_name          = var.project_name
  environment           = var.environment
  region                = var.region
  vpc_cidr              = var.vpc_cidr
  subnet_cidr           = var.subnet_cidr
  allowed_ssh_cidr      = var.allowed_ssh_cidr
  allowed_http_cidr     = var.allowed_http_cidr
  allowed_https_cidr    = var.allowed_https_cidr
  labels                = local.common_labels
  tags                  = var.tags
}

################################################################################
# Compute Module
################################################################################

module "compute" {
  source = "./modules/compute"
  
  cloud_provider      = local.cloud_provider_lower
  project_name        = var.project_name
  environment         = var.environment
  region              = var.region
  instance_name       = var.instance_name
  instance_type       = var.instance_type
  os_image            = var.os_image
  disk_size_gb        = var.disk_size_gb
  enable_public_ip    = var.enable_public_ip
  vpc_id              = module.networking.vpc_id
  subnet_id           = module.networking.subnet_id
  security_group_id   = module.networking.security_group_id
  labels              = local.common_labels
  tags                = var.tags
  user_data           = base64encode(templatefile("${path.module}/scripts/user_data.sh", {
    docker_registry = var.docker_registry
  }))
}

################################################################################
# Storage Module
################################################################################

module "storage" {
  source = "./modules/storage"
  
  cloud_provider      = local.cloud_provider_lower
  project_name        = var.project_name
  environment         = var.environment
  region              = var.region
  instance_id         = module.compute.instance_id
  storage_size_gb     = var.storage_size_gb
  enable_backup       = var.enable_backup
  backup_retention    = var.backup_retention_days
  labels              = local.common_labels
  tags                = var.tags
}

################################################################################
# DNS Module
################################################################################

module "dns" {
  source = "./modules/dns"
  
  cloud_provider      = local.cloud_provider_lower
  domain_name         = var.domain_name
  dns_provider        = var.dns_provider
  public_ip           = module.compute.public_ip
  cloudflare_zone_id  = var.cloudflare_zone_id
  labels              = local.common_labels
  tags                = var.tags
}
