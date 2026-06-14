################################################################################
# DNS Module - Outputs
################################################################################

output "dns_records" {
  description = "DNS records created"
  value = {
    domain_name = var.domain_name
    public_ip   = var.public_ip
    dns_provider = var.dns_provider
    a_record = (
      var.dns_provider == "cloudflare" && length(cloudflare_record.main) > 0 ? cloudflare_record.main[0].name :
      var.dns_provider == "route53" && length(aws_route53_record.main) > 0 ? aws_route53_record.main[0].name :
      var.dns_provider == "gcloud" && length(google_dns_record_set.main) > 0 ? google_dns_record_set.main[0].name :
      var.dns_provider == "azure-dns" && length(azurerm_dns_a_record.main) > 0 ? azurerm_dns_a_record.main[0].name :
      var.dns_provider == "alibaba-dns" && length(alicloud_dns_record.main) > 0 ? alicloud_dns_record.main[0].host_record :
      var.dns_provider == "oracle-dns" && length(oci_dns_rrset.main) > 0 ? oci_dns_rrset.main[0].domain :
      "Not configured"
    )
  }
}
