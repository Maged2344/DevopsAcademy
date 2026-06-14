terraform {
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
  }
}

################################################################################
# Storage Module - AWS EBS
################################################################################

resource "aws_ebs_volume" "main" {
  count             = var.cloud_provider == "aws" ? 1 : 0
  availability_zone = data.aws_instance.main[0].availability_zone
  size              = var.storage_size_gb
  type              = "gp3"
  iops              = 3000
  throughput        = 125
  encrypted         = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-volume"
  })
}

resource "aws_volume_attachment" "main" {
  count       = var.cloud_provider == "aws" ? 1 : 0
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.main[0].id
  instance_id = var.instance_id
}

resource "aws_dlm_lifecycle_policy" "main" {
  count              = var.cloud_provider == "aws" && var.enable_backup ? 1 : 0
  description        = "Backup policy for ${var.project_name}"
  execution_role_arn = data.aws_iam_role.dlm[0].arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "Daily Snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["03:00"]
      }

      retain_rule {
        count = var.backup_retention
      }

      tags_to_add = merge(var.tags, {
        Name = "${var.project_name}-snapshot"
      })

      copy_tags = true
    }
  }
}

data "aws_instance" "main" {
  count       = var.cloud_provider == "aws" ? 1 : 0
  instance_id = var.instance_id
}

data "aws_iam_role" "dlm" {
  count = var.cloud_provider == "aws" && var.enable_backup ? 1 : 0
  name  = "AWSDataLifecycleManagerDefaultRole"
}

################################################################################
# Storage Module - GCP Persistent Disk
################################################################################

resource "google_compute_disk" "main" {
  count = var.cloud_provider == "gcp" ? 1 : 0
  name  = "${var.project_name}-disk"
  zone  = "${var.region}-a"
  size  = var.storage_size_gb
  type  = "pd-standard"

  labels = merge(var.labels, {
    environment = var.environment
  })
}

resource "google_compute_attached_disk" "main" {
  count    = var.cloud_provider == "gcp" ? 1 : 0
  disk     = google_compute_disk.main[0].id
  instance = var.instance_id
}

resource "google_compute_snapshot" "main" {
  count             = var.cloud_provider == "gcp" && var.enable_backup ? 1 : 0
  name              = "${var.project_name}-snapshot"
  source_disk       = google_compute_disk.main[0].id
  storage_locations = [var.region]

  labels = merge(var.labels, {
    environment = var.environment
  })
}

################################################################################
# Storage Module - Azure Managed Disks
################################################################################

resource "azurerm_managed_disk" "main" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  name                 = "${var.project_name}-datadisk"
  location             = var.region
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.storage_size_gb

  tags = var.tags
}

################################################################################
# Storage Module - Alibaba Cloud Disk
################################################################################

resource "alicloud_disk" "main" {
  count    = var.cloud_provider == "alibaba" ? 1 : 0
  name     = "${var.project_name}-disk"
  zone_id  = data.alicloud_zones.available[0].zones[0].id
  size     = var.storage_size_gb
  category = "cloud_efficiency"

  tags = merge(var.tags, {
    Name = "${var.project_name}-disk"
  })
}

resource "alicloud_disk_attachment" "main" {
  count       = var.cloud_provider == "alibaba" ? 1 : 0
  disk_id     = alicloud_disk.main[0].id
  instance_id = var.instance_id
}

data "alicloud_zones" "available" {
  count = var.cloud_provider == "alibaba" ? 1 : 0
}

################################################################################
# Storage Module - Oracle Cloud Block Storage
################################################################################

resource "oci_core_volume" "main" {
  count               = var.cloud_provider == "oracle" ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads[0].availability_domains[0].name
  compartment_id      = var.tenancy_ocid
  display_name        = "${var.project_name}-volume"
  size_in_gbs         = var.storage_size_gb

  defined_tags = var.labels
}

resource "oci_core_volume_attachment" "main" {
  count           = var.cloud_provider == "oracle" ? 1 : 0
  attachment_type = "iscsi"
  instance_id     = var.instance_id
  volume_id       = oci_core_volume.main[0].id
  device          = "/dev/oracleoci/oraclevdb"
}

resource "oci_core_volume_backup" "main" {
  count        = var.cloud_provider == "oracle" && var.enable_backup ? 1 : 0
  display_name = "${var.project_name}-backup"
  volume_id    = oci_core_volume.main[0].id
  type         = "INCREMENTAL"
}

data "oci_identity_availability_domains" "ads" {
  count          = var.cloud_provider == "oracle" ? 1 : 0
  compartment_id = var.tenancy_ocid
}
