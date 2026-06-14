################################################################################
# Storage Module - Outputs
################################################################################

output "volume_id" {
  description = "Storage volume ID"
  value = (
    var.cloud_provider == "aws" ? aws_ebs_volume.main[0].id :
    var.cloud_provider == "gcp" ? google_compute_disk.main[0].id :
    var.cloud_provider == "azure" ? azurerm_managed_disk.main[0].id :
    var.cloud_provider == "alibaba" ? alicloud_disk.main[0].id :
    var.cloud_provider == "oracle" ? oci_core_volume.main[0].id :
    ""
  )
}

output "mount_point" {
  description = "Mount point for storage"
  value = (
    var.cloud_provider == "aws" ? "/dev/sdf" :
    var.cloud_provider == "gcp" ? "/dev/disk/by-id/google-${var.project_name}-disk" :
    var.cloud_provider == "azure" ? "/dev/sdc" :
    var.cloud_provider == "alibaba" ? "/dev/vdb" :
    var.cloud_provider == "oracle" ? "/dev/oracleoci/oraclevdb" :
    ""
  )
}

output "volume_size_gb" {
  description = "Volume size in GB"
  value       = var.storage_size_gb
}
