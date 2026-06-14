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
# Networking Module - AWS Implementation
################################################################################

resource "aws_vpc" "main" {
  count                = var.cloud_provider == "aws" ? 1 : 0
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-vpc"
  })
}

resource "aws_internet_gateway" "main" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  tags = merge(var.tags, {
    Name = "${var.project_name}-igw"
  })
}

resource "aws_subnet" "main" {
  count                   = var.cloud_provider == "aws" ? 1 : 0
  vpc_id                  = aws_vpc.main[0].id
  cidr_block              = var.subnet_cidr
  availability_zone       = data.aws_availability_zones.available[0].names[0]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-subnet"
  })
}

resource "aws_route_table" "main" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-rt"
  })
}

resource "aws_route_table_association" "main" {
  count          = var.cloud_provider == "aws" ? 1 : 0
  subnet_id      = aws_subnet.main[0].id
  route_table_id = aws_route_table.main[0].id
}

resource "aws_security_group" "main" {
  count       = var.cloud_provider == "aws" ? 1 : 0
  name        = "${var.project_name}-sg"
  description = "Security group for ${var.project_name}"
  vpc_id      = aws_vpc.main[0].id

  # SSH
  dynamic "ingress" {
    for_each = var.allowed_ssh_cidr
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # HTTP
  dynamic "ingress" {
    for_each = var.allowed_http_cidr
    content {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # HTTPS
  dynamic "ingress" {
    for_each = var.allowed_https_cidr
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-sg"
  })
}

data "aws_availability_zones" "available" {
  count = var.cloud_provider == "aws" ? 1 : 0
  state = "available"
}

################################################################################
# Networking Module - GCP Implementation
################################################################################

resource "google_compute_network" "main" {
  count                   = var.cloud_provider == "gcp" ? 1 : 0
  name                    = "${var.project_name}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  count         = var.cloud_provider == "gcp" ? 1 : 0
  name          = "${var.project_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.main[0].id
}

resource "google_compute_firewall" "allow_ssh" {
  count   = var.cloud_provider == "gcp" ? 1 : 0
  name    = "${var.project_name}-allow-ssh"
  network = google_compute_network.main[0].name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ssh_cidr
}

resource "google_compute_firewall" "allow_http" {
  count   = var.cloud_provider == "gcp" ? 1 : 0
  name    = "${var.project_name}-allow-http"
  network = google_compute_network.main[0].name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = var.allowed_http_cidr
}

resource "google_compute_firewall" "allow_https" {
  count   = var.cloud_provider == "gcp" ? 1 : 0
  name    = "${var.project_name}-allow-https"
  network = google_compute_network.main[0].name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = var.allowed_https_cidr
}

resource "google_compute_firewall" "allow_internal" {
  count   = var.cloud_provider == "gcp" ? 1 : 0
  name    = "${var.project_name}-allow-internal"
  network = google_compute_network.main[0].name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [var.subnet_cidr]
}

################################################################################
# Networking Module - Azure Implementation
################################################################################

resource "azurerm_resource_group" "main" {
  count    = var.cloud_provider == "azure" ? 1 : 0
  name     = "${var.project_name}-rg"
  location = var.region
}

resource "azurerm_virtual_network" "main" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  name                = "${var.project_name}-vnet"
  address_space       = [var.vpc_cidr]
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name
}

resource "azurerm_subnet" "main" {
  count                = var.cloud_provider == "azure" ? 1 : 0
  name                 = "${var.project_name}-subnet"
  resource_group_name  = azurerm_resource_group.main[0].name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = [var.subnet_cidr]
}

resource "azurerm_network_security_group" "main" {
  count               = var.cloud_provider == "azure" ? 1 : 0
  name                = "${var.project_name}-nsg"
  location            = azurerm_resource_group.main[0].location
  resource_group_name = azurerm_resource_group.main[0].name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = var.allowed_http_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.allowed_https_cidr
    destination_address_prefix = "*"
  }
}

################################################################################
# Networking Module - Alibaba Cloud Implementation
################################################################################

resource "alicloud_vpc" "main" {
  count      = var.cloud_provider == "alibaba" ? 1 : 0
  vpc_name   = "${var.project_name}-vpc"
  cidr_block = var.vpc_cidr
}

resource "alicloud_vswitch" "main" {
  count        = var.cloud_provider == "alibaba" ? 1 : 0
  vpc_id       = alicloud_vpc.main[0].id
  cidr_block   = var.subnet_cidr
  zone_id      = data.alicloud_zones.available[0].zones[0].id
  vswitch_name = "${var.project_name}-vswitch"
}

resource "alicloud_security_group" "main" {
  count  = var.cloud_provider == "alibaba" ? 1 : 0
  vpc_id = alicloud_vpc.main[0].id
  name   = "${var.project_name}-sg"
}

resource "alicloud_security_group_rule" "ssh" {
  count             = var.cloud_provider == "alibaba" ? 1 : 0
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "22/22"
  security_group_id = alicloud_security_group.main[0].id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "http" {
  count             = var.cloud_provider == "alibaba" ? 1 : 0
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "80/80"
  security_group_id = alicloud_security_group.main[0].id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "https" {
  count             = var.cloud_provider == "alibaba" ? 1 : 0
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.main[0].id
  cidr_ip           = "0.0.0.0/0"
}

data "alicloud_zones" "available" {
  count = var.cloud_provider == "alibaba" ? 1 : 0
}

################################################################################
# Networking Module - Oracle Cloud Implementation
################################################################################

resource "oci_core_vcn" "main" {
  count          = var.cloud_provider == "oracle" ? 1 : 0
  compartment_id = var.tenancy_ocid # This should be passed as variable
  cidr_block     = var.vpc_cidr
  display_name   = "${var.project_name}-vcn"
}

resource "oci_core_subnet" "main" {
  count          = var.cloud_provider == "oracle" ? 1 : 0
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.main[0].id
  cidr_block     = var.subnet_cidr
  display_name   = "${var.project_name}-subnet"
  route_table_id = oci_core_route_table.main[0].id
}

resource "oci_core_internet_gateway" "main" {
  count          = var.cloud_provider == "oracle" ? 1 : 0
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.main[0].id
  display_name   = "${var.project_name}-igw"
}

resource "oci_core_route_table" "main" {
  count          = var.cloud_provider == "oracle" ? 1 : 0
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.main[0].id
  display_name   = "${var.project_name}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.main[0].id
  }
}

resource "oci_core_security_list" "main" {
  count          = var.cloud_provider == "oracle" ? 1 : 0
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.main[0].id
  display_name   = "${var.project_name}-sl"

  ingress_security_rules {
    protocol = 6 # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = 6
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = 6
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}
