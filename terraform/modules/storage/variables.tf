################################################################################
# Storage Module - Variables
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
  description = "Environment"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "instance_id" {
  description = "Instance ID to attach storage to"
  type        = string
}

variable "storage_size_gb" {
  description = "Storage size in GB"
  type        = number
  default     = 100
}

variable "enable_backup" {
  description = "Enable backups"
  type        = bool
  default     = true
}

variable "backup_retention" {
  description = "Backup retention days"
  type        = number
  default     = 30
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

variable "labels" {
  description = "Labels"
  type        = map(string)
}

variable "tags" {
  description = "Tags"
  type        = map(string)
}
