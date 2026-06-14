################################################################################
# Networking Module - Outputs
################################################################################

output "vpc_id" {
  description = "VPC/Network ID"
  value = (
    var.cloud_provider == "aws" ? aws_vpc.main[0].id :
    var.cloud_provider == "gcp" ? google_compute_network.main[0].id :
    var.cloud_provider == "azure" ? azurerm_virtual_network.main[0].id :
    var.cloud_provider == "alibaba" ? alicloud_vpc.main[0].id :
    var.cloud_provider == "oracle" ? oci_core_vcn.main[0].id :
    ""
  )
}

output "subnet_id" {
  description = "Subnet ID"
  value = (
    var.cloud_provider == "aws" ? aws_subnet.main[0].id :
    var.cloud_provider == "gcp" ? google_compute_subnetwork.main[0].id :
    var.cloud_provider == "azure" ? azurerm_subnet.main[0].id :
    var.cloud_provider == "alibaba" ? alicloud_vswitch.main[0].id :
    var.cloud_provider == "oracle" ? oci_core_subnet.main[0].id :
    ""
  )
}

output "security_group_id" {
  description = "Security Group ID"
  value = (
    var.cloud_provider == "aws" ? aws_security_group.main[0].id :
    var.cloud_provider == "azure" ? azurerm_network_security_group.main[0].id :
    var.cloud_provider == "alibaba" ? alicloud_security_group.main[0].id :
    var.cloud_provider == "oracle" ? oci_core_security_list.main[0].id :
    ""
  )
}

output "resource_group_name" {
  description = "Azure Resource Group Name (Azure only)"
  value = (
    var.cloud_provider == "azure" ? azurerm_resource_group.main[0].name : null
  )
}
