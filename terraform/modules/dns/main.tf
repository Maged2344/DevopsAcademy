################################################################################
# DNS Module - Cloudflare (Universal Provider)
################################################################################

resource "cloudflare_record" "main" {
  count   = var.dns_provider == "cloudflare" ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  type    = "A"
  value   = var.public_ip
  ttl     = 300
}

resource "cloudflare_record" "www" {
  count   = var.dns_provider == "cloudflare" ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  value   = var.domain_name
  ttl     = 300
}

################################################################################
# DNS Module - AWS Route53
################################################################################

data "aws_route53_zone" "main" {
  count = var.cloud_provider == "aws" && var.dns_provider == "route53" ? 1 : 0
  name  = "${var.domain_name}."
}

resource "aws_route53_record" "main" {
  count   = var.cloud_provider == "aws" && var.dns_provider == "route53" ? 1 : 0
  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 300
  records = [var.public_ip]
}

resource "aws_route53_record" "www" {
  count   = var.cloud_provider == "aws" && var.dns_provider == "route53" ? 1 : 0
  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [var.domain_name]
}

################################################################################
# DNS Module - Google Cloud DNS
################################################################################

data "google_dns_managed_zone" "main" {
  count = var.cloud_provider == "gcp" && var.dns_provider == "gcloud" ? 1 : 0
  name  = replace(var.domain_name, ".", "-")
}

resource "google_dns_record_set" "main" {
  count = var.cloud_provider == "gcp" && var.dns_provider == "gcloud" ? 1 : 0
  name  = "${var.domain_name}."
  type  = "A"
  ttl   = 300
  managed_zone = data.google_dns_managed_zone.main[0].name
  rrdatas = [var.public_ip]
}

resource "google_dns_record_set" "www" {
  count = var.cloud_provider == "gcp" && var.dns_provider == "gcloud" ? 1 : 0
  name  = "www.${var.domain_name}."
  type  = "CNAME"
  ttl   = 300
  managed_zone = data.google_dns_managed_zone.main[0].name
  rrdatas = ["${var.domain_name}."]
}

################################################################################
# DNS Module - Azure DNS
################################################################################

data "azurerm_dns_zone" "main" {
  count               = var.cloud_provider == "azure" && var.dns_provider == "azure-dns" ? 1 : 0
  name                = var.domain_name
  resource_group_name = data.azurerm_resource_group.main[0].name
}

resource "azurerm_dns_a_record" "main" {
  count               = var.cloud_provider == "azure" && var.dns_provider == "azure-dns" ? 1 : 0
  name                = "@"
  zone_name           = data.azurerm_dns_zone.main[0].name
  resource_group_name = data.azurerm_resource_group.main[0].name
  ttl                 = 300
  records             = [var.public_ip]
}

resource "azurerm_dns_cname_record" "www" {
  count               = var.cloud_provider == "azure" && var.dns_provider == "azure-dns" ? 1 : 0
  name                = "www"
  zone_name           = data.azurerm_dns_zone.main[0].name
  resource_group_name = data.azurerm_resource_group.main[0].name
  ttl                 = 300
  record              = var.domain_name
}

data "azurerm_resource_group" "main" {
  count = var.cloud_provider == "azure" && var.dns_provider == "azure-dns" ? 1 : 0
  name  = "devops-academy-rg"
}

################################################################################
# DNS Module - Alibaba Cloud DNS
################################################################################

resource "alicloud_dns_record" "main" {
  count       = var.cloud_provider == "alibaba" && var.dns_provider == "alibaba-dns" ? 1 : 0
  zone_name   = var.domain_name
  host_record = "@"
  type        = "A"
  value       = var.public_ip
  ttl         = 600
}

resource "alicloud_dns_record" "www" {
  count       = var.cloud_provider == "alibaba" && var.dns_provider == "alibaba-dns" ? 1 : 0
  zone_name   = var.domain_name
  host_record = "www"
  type        = "CNAME"
  value       = var.domain_name
  ttl         = 600
}

################################################################################
# DNS Module - Oracle Cloud DNS
################################################################################

data "oci_dns_zones" "main" {
  count          = var.cloud_provider == "oracle" && var.dns_provider == "oracle-dns" ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = var.domain_name
}

resource "oci_dns_rrset" "main" {
  count           = var.cloud_provider == "oracle" && var.dns_provider == "oracle-dns" ? 1 : 0
  zone_name_or_id = data.oci_dns_zones.main[0].zones[0].id
  domain          = var.domain_name
  rtype           = "A"
  ttl             = 300
  
  items {
    domain = var.domain_name
    rdata  = var.public_ip
    rrtype = "A"
    ttl    = 300
  }
}

resource "oci_dns_rrset" "www" {
  count           = var.cloud_provider == "oracle" && var.dns_provider == "oracle-dns" ? 1 : 0
  zone_name_or_id = data.oci_dns_zones.main[0].zones[0].id
  domain          = "www.${var.domain_name}"
  rtype           = "CNAME"
  ttl             = 300
  
  items {
    domain = "www.${var.domain_name}"
    rdata  = var.domain_name
    rrtype = "CNAME"
    ttl    = 300
  }
}
