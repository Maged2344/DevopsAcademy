################################################################################
# Compute Module - Variables
################################################################################

variable "cloud_provider" {
  description = "Cloud provider"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "instance_name" {
  description = "Instance name"
  type        = string
}

variable "instance_type" {
  description = "Instance type/size"
  type        = string
  default     = "medium"
}

variable "os_image" {
  description = "OS image"
  type        = string
}

variable "disk_size_gb" {
  description = "Root disk size in GB"
  type        = number
  default     = 50
}

variable "enable_public_ip" {
  description = "Enable public IP"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

variable "labels" {
  description = "Labels"
  type        = map(string)
}

variable "tags" {
  description = "Tags"
  type        = map(string)
}

variable "resource_group_name" {
  description = "Azure Resource Group Name"
  type        = string
  default     = ""
}

variable "tenancy_ocid" {
  description = "Oracle Cloud Tenancy OCID"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "User data script (base64 encoded)"
  type        = string
  default     = ""
}

################################################################################
# Local Variables for Instance Type Mapping
################################################################################

locals {
  instance_type_map = {
    small = {
      aws     = "t3.small"
      gcp     = "e2-small"
      azure   = "Standard_B1s"
      alibaba = "ecs.t6-c1m1.small"
      oracle  = "VM.Standard3.Flex"
    }
    medium = {
      aws     = "t3.medium"
      gcp     = "e2-medium"
      azure   = "Standard_B2s"
      alibaba = "ecs.t6-c1m2.medium"
      oracle  = "VM.Standard3.Flex"
    }
    large = {
      aws     = "t3.large"
      gcp     = "e2-large"
      azure   = "Standard_B2ms"
      alibaba = "ecs.t6-c1m4.large"
      oracle  = "VM.Standard3.Flex"
    }
  }

  resolved_instance_type = local.instance_type_map[var.instance_type][var.cloud_provider]

  image_map = {
    ubuntu-2404-lts = {
      aws     = "ami-0c02fb55b74e6f7b6" # Placeholder - should be looked up
      gcp     = "ubuntu-2404-lts"
      azure   = "UbuntuServer:2404-lts:20.04-LTS:latest"
      alibaba = "ubuntu_22_04_x64_20G_alibase_20230919.vhd"
      oracle  = "Canonical-Ubuntu-24.04-LTS"
    }
  }
}
