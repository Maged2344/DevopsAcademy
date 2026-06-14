################################################################################
# Compute Outputs
################################################################################

output "instance_id" {
  description = "ID of the compute instance"
  value       = module.compute.instance_id
}

output "instance_name" {
  description = "Name of the compute instance"
  value       = module.compute.instance_name
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = module.compute.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = module.compute.private_ip
}

output "instance_username" {
  description = "Default username for SSH access"
  value       = module.compute.instance_username
}

################################################################################
# Networking Outputs
################################################################################

output "vpc_id" {
  description = "VPC/Network ID"
  value       = module.networking.vpc_id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = module.networking.subnet_id
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.networking.security_group_id
}

################################################################################
# DNS Outputs
################################################################################

output "domain_name" {
  description = "Domain name configured"
  value       = var.domain_name
}

output "dns_records" {
  description = "DNS records created"
  value       = module.dns.dns_records
}

################################################################################
# Storage Outputs
################################################################################

output "storage_volume_id" {
  description = "ID of the storage volume"
  value       = module.storage.volume_id
}

output "storage_mount_point" {
  description = "Mount point for storage volume"
  value       = module.storage.mount_point
}

################################################################################
# SSH Connection Details
################################################################################

output "ssh_connection_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i <your-key-file> ${module.compute.instance_username}@${module.compute.public_ip}"
}

################################################################################
# Deployment Information
################################################################################

output "deployment_info" {
  description = "Deployment summary"
  value = {
    cloud_provider = lower(var.cloud_provider)
    region         = var.region
    instance_ip    = module.compute.public_ip
    domain_name    = var.domain_name
    public_ip      = module.compute.public_ip
    status         = "Deployed successfully"
  }
}
