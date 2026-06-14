#!/bin/bash
set -e

# DevOps Academy Docker Deployment Script
# This script installs Docker, Docker Compose, and deploys the infrastructure

echo "==============================================="
echo "DevOps Academy Infrastructure Initialization"
echo "==============================================="

# Update system
apt-get update
apt-get upgrade -y

# Install required packages
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    build-essential

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# Install Docker Compose
curl -fsSL https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Verify installations
echo "Docker version:"
docker --version

echo "Docker Compose version:"
docker-compose --version

# Add ubuntu user to docker group
usermod -aG docker ubuntu || true

# Create directories for persistent volumes
mkdir -p /data/prometheus
mkdir -p /data/grafana
mkdir -p /data/mongo
mkdir -p /data/app

# Set permissions
chmod -R 755 /data

# Create mount point for additional storage
if [ -b /dev/sdf ] || [ -b /dev/vdb ] || [ -b /dev/sdc ] || [ -b /dev/xvdf ]; then
    echo "Storage volume detected, formatting..."
    
    # Determine which device to use
    DEVICE=""
    for dev in /dev/sdf /dev/vdb /dev/sdc /dev/xvdf; do
        if [ -b "$dev" ]; then
            DEVICE=$dev
            break
        fi
    done
    
    if [ ! -z "$DEVICE" ]; then
        # Format the device
        mkfs.ext4 -F $DEVICE
        
        # Mount it
        mkdir -p /mnt/data
        mount $DEVICE /mnt/data
        
        # Add to fstab for persistence
        echo "$DEVICE /mnt/data ext4 defaults,nofail 0 0" >> /etc/fstab
        
        # Create directories on mounted volume
        mkdir -p /mnt/data/docker
        chmod -R 755 /mnt/data
    fi
fi

# Start Docker service
systemctl enable docker
systemctl start docker

echo "==============================================="
echo "Docker installation and configuration complete!"
echo "==============================================="
echo ""
echo "Next steps:"
echo "1. Clone the repository"
echo "2. Deploy Docker Compose stack:"
echo "   cd /path/to/devopsacademy"
echo "   docker-compose up -d"
echo ""
echo "Volumes:"
echo "- Prometheus data: /data/prometheus"
echo "- Grafana data: /data/grafana"
echo "- MongoDB data: /data/mongo"
echo "- Application data: /data/app"
echo "- Additional storage: /mnt/data (if attached)"
