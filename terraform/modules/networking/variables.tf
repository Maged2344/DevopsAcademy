################################################################################
# Networking Module - Variables
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

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR block"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks for SSH"
  type        = list(string)
}

variable "allowed_http_cidr" {
  description = "CIDR blocks for HTTP"
  type        = list(string)
}

variable "allowed_https_cidr" {
  description = "CIDR blocks for HTTPS"
  type        = list(string)
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
