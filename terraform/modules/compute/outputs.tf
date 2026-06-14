################################################################################
# Compute Module - Outputs
################################################################################

output "instance_id" {
  description = "Instance ID"
  value = (
    var.cloud_provider == "aws" ? aws_instance.main[0].id :
    var.cloud_provider == "gcp" ? google_compute_instance.main[0].id :
    var.cloud_provider == "azure" ? azurerm_virtual_machine.main[0].id :
    var.cloud_provider == "alibaba" ? alicloud_instance.main[0].id :
    var.cloud_provider == "oracle" ? oci_core_instance.main[0].id :
    ""
  )
}

output "instance_name" {
  description = "Instance name"
  value = (
    var.cloud_provider == "aws" ? aws_instance.main[0].tags["Name"] :
    var.cloud_provider == "gcp" ? google_compute_instance.main[0].name :
    var.cloud_provider == "azure" ? azurerm_virtual_machine.main[0].name :
    var.cloud_provider == "alibaba" ? alicloud_instance.main[0].instance_name :
    var.cloud_provider == "oracle" ? oci_core_instance.main[0].display_name :
    ""
  )
}

output "public_ip" {
  description = "Public IP address"
  value = (
    var.cloud_provider == "aws" ? (var.enable_public_ip ? aws_eip.main[0].public_ip : aws_instance.main[0].public_ip) :
    var.cloud_provider == "gcp" ? google_compute_instance.main[0].network_interface[0].access_config[0].nat_ip :
    var.cloud_provider == "azure" ? (var.enable_public_ip ? azurerm_public_ip.main[0].ip_address : "") :
    var.cloud_provider == "alibaba" ? alicloud_instance.main[0].public_ip :
    var.cloud_provider == "oracle" ? oci_core_instance.main[0].public_ip :
    ""
  )
}

output "private_ip" {
  description = "Private IP address"
  value = (
    var.cloud_provider == "aws" ? aws_instance.main[0].private_ip :
    var.cloud_provider == "gcp" ? google_compute_instance.main[0].network_interface[0].network_ip :
    var.cloud_provider == "azure" ? azurerm_network_interface.main[0].private_ip_address :
    var.cloud_provider == "alibaba" ? alicloud_instance.main[0].private_ip :
    var.cloud_provider == "oracle" ? oci_core_instance.main[0].private_ip :
    ""
  )
}

output "instance_username" {
  description = "Default SSH username"
  value = (
    var.cloud_provider == "aws" ? "ubuntu" :
    var.cloud_provider == "gcp" ? "ubuntu" :
    var.cloud_provider == "azure" ? "azureuser" :
    var.cloud_provider == "alibaba" ? "root" :
    var.cloud_provider == "oracle" ? "ubuntu" :
    ""
  )
}
