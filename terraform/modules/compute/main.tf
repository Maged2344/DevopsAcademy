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
# Compute Module - AWS Implementation
################################################################################

data "aws_ami" "ubuntu" {
  count       = var.cloud_provider == "aws" ? 1 : 0
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "main" {
  count                       = var.cloud_provider == "aws" ? 1 : 0
  ami                         = data.aws_ami.ubuntu[0].id
  instance_type               = local.resolved_instance_type
  subnet_id                   = var.subnet_id
  security_groups             = [var.security_group_id]
  associate_public_ip_address = var.enable_public_ip

  root_block_device {
    volume_type = "gp3"
    volume_size = var.disk_size_gb
  }

  user_data = base64decode(var.user_data)

  tags = merge(var.tags, {
    Name = var.instance_name
  })

  monitoring = true
}

resource "aws_eip" "main" {
  count    = var.cloud_provider == "aws" && var.enable_public_ip ? 1 : 0
  instance = aws_instance.main[0].id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.instance_name}-eip"
  })

  depends_on = [aws_instance.main]
}

################################################################################
# Compute Module - GCP Implementation
################################################################################

resource "google_compute_instance" "main" {
  count        = var.cloud_provider == "gcp" ? 1 : 0
  name         = var.instance_name
  machine_type = local.resolved_instance_type
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts"
      size  = var.disk_size_gb
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.subnet_id
    access_config {
      nat_ip = null # Auto-assign public IP
    }
  }

  metadata = {
    startup-script = base64decode(var.user_data)
  }

  labels = merge(var.labels, {
    environment = var.environment
  })

  tags = [var.environment, "docker"]
}

################################################################################
# Compute Module - Azure Implementation
################################################################################

resource "azurerm_network_interface" "main" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  name                = "${var.instance_name}-nic"
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.main[0].id : null
  }
}

resource "azurerm_public_ip" "main" {
  count               = var.cloud_provider == "azure" && var.enable_public_ip ? 1 : 0
  name                = "${var.instance_name}-pip"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_virtual_machine" "main" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  name                = var.instance_name
  location            = var.region
  resource_group_name = var.resource_group_name
  vm_size             = local.resolved_instance_type

  network_interface_ids = [
    azurerm_network_interface.main[0].id,
  ]

  os_profile {
    computer_name  = var.instance_name
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }

  storage_os_disk {
    name              = "${var.instance_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = var.disk_size_gb
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = var.tags
}

################################################################################
# Compute Module - Alibaba Cloud Implementation
################################################################################

resource "alicloud_instance" "main" {
  count                = var.cloud_provider == "alibaba" ? 1 : 0
  instance_name        = var.instance_name
  instance_type        = local.resolved_instance_type
  image_id             = data.alicloud_images.ubuntu[0].images[0].id
  security_groups      = [var.security_group_id]
  vswitch_id           = var.subnet_id
  system_disk_size     = var.disk_size_gb
  system_disk_category = "cloud_efficiency"

  internet_max_bandwidth_out = var.enable_public_ip ? 100 : 0

  user_data = base64decode(var.user_data)

  tags = merge(var.tags, {
    Name = var.instance_name
  })
}

data "alicloud_images" "ubuntu" {
  count      = var.cloud_provider == "alibaba" ? 1 : 0
  owners     = "system"
  name_regex = "^ubuntu_24"
}

################################################################################
# Compute Module - Oracle Cloud Implementation
################################################################################

resource "oci_core_instance" "main" {
  count               = var.cloud_provider == "oracle" ? 1 : 0
  availability_domain = data.oci_identity_availability_domains.ads[0].availability_domains[0].name
  compartment_id      = var.tenancy_ocid
  shape               = local.resolved_instance_type
  display_name        = var.instance_name

  create_vnic_details {
    subnet_id                 = var.subnet_id
    assign_public_ip          = var.enable_public_ip
    assign_private_dns_record = true
  }

  source_details {
    source_type             = "IMAGE"
    source_id               = data.oci_core_images.ubuntu[0].images[0].id
    boot_volume_size_in_gbs = var.disk_size_gb
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = var.user_data
  }

  defined_tags = var.labels
}

data "oci_identity_availability_domains" "ads" {
  count          = var.cloud_provider == "oracle" ? 1 : 0
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "ubuntu" {
  count                    = var.cloud_provider == "oracle" ? 1 : 0
  compartment_id           = var.tenancy_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = local.resolved_instance_type
}
