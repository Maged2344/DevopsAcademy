################################################################################
# DNS Module - Variables
################################################################################

variable "cloud_provider" {
  description = "Cloud provider"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "dns_provider" {
  description = "DNS provider (cloudflare, route53, gcloud, azure-dns, alibaba-dns, oracle-dns)"
  type        = string
  default     = "cloudflare"
}

variable "public_ip" {
  description = "Public IP to point domain to"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
  default     = ""
  sensitive   = true
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
