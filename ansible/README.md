# Ansible Configuration Management - DevOps Academy

Automated server configuration and application deployment using Ansible. This handles everything from initial server setup to full application deployment with SSL, monitoring, and automated backups.

## Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Ansible Control Node                       │
│                   (Your local machine)                        │
└─────────────────────┬───────────────────────────────────────┘
                      │ SSH
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    Target Server                              │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌───────┐  ┌────────────────┐ │
│  │  Common   │  │  Docker  │  │  App  │  │   Monitoring   │ │
│  │  (system) │  │  Engine  │  │Deploy │  │ Prom + Grafana │ │
│  └──────────┘  └──────────┘  └───────┘  └────────────────┘ │
│                                                              │
│  ┌──────────┐  ┌──────────────────────────────────────────┐ │
│  │   SSL    │  │        Docker Compose (8 services)        │ │
│  │ LetsEnc  │  │  web, backend, mongo, prometheus,         │ │
│  └──────────┘  │  grafana, node-exp, nginx-exp, mongo-exp  │ │
│                └──────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

| Tool | Version | Installation |
|------|---------|-------------|
| Ansible | >= 2.14 | `pip install ansible` |
| Python | >= 3.9 | System package manager |
| SSH Key | - | `ssh-keygen -t rsa -b 4096` |

```bash
# Install Ansible
pip install ansible

# Install required collections
cd ansible
ansible-galaxy install -r requirements.yml

# Verify
ansible --version
```

## Directory Structure

```
ansible/
├── ansible.cfg                 # Ansible configuration
├── requirements.yml            # Galaxy collection dependencies
├── inventory/
│   ├── hosts.yml              # Server inventory
│   └── group_vars/
│       └── all.yml            # Global variables
├── playbooks/
│   ├── site.yml               # Full infrastructure setup
│   ├── deploy.yml             # Quick app deployment
│   ├── rollback.yml           # Rollback to specific commit
│   └── setup.yml              # Initial server setup only
└── roles/
    ├── common/                # System packages, firewall, fail2ban
    │   ├── tasks/main.yml
    │   └── handlers/main.yml
    ├── docker/                # Docker Engine + Compose
    │   ├── tasks/main.yml
    │   └── handlers/main.yml
    ├── app/                   # Clone repo, deploy containers
    │   ├── tasks/main.yml
    │   └── templates/env.j2
    ├── ssl/                   # Let's Encrypt certificates
    │   └── tasks/main.yml
    └── monitoring/            # Prometheus + Grafana config
        ├── tasks/main.yml
        ├── handlers/main.yml
        └── templates/
            ├── prometheus.yml.j2
            └── alerts.yml.j2
```

## Quick Start

### 1. Configure Inventory

Edit `inventory/hosts.yml` with your server IP:

```yaml
all:
  children:
    webservers:
      hosts:
        production:
          ansible_host: YOUR_SERVER_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

Or use environment variables:
```bash
export SERVER_IP=20.25.62.124
export SSH_KEY_PATH=~/.ssh/id_rsa
```

### 2. Test Connection

```bash
cd ansible
ansible all -m ping
```

### 3. Run Full Setup

```bash
# Full infrastructure setup (first time)
ansible-playbook playbooks/site.yml

# Quick deployment (code changes only)
ansible-playbook playbooks/deploy.yml

# Setup server only (no app)
ansible-playbook playbooks/setup.yml
```

## Playbooks

### `site.yml` - Full Infrastructure Setup

Runs all roles in order: common → docker → app → ssl → monitoring

```bash
# Full setup
ansible-playbook playbooks/site.yml

# Skip SSL (for HTTP-only environments)
ansible-playbook playbooks/site.yml --skip-tags ssl

# Only run specific roles
ansible-playbook playbooks/site.yml --tags docker,app
```

### `deploy.yml` - Quick Deployment

Pulls latest code, rebuilds containers, and verifies health. Use for code updates.

```bash
ansible-playbook playbooks/deploy.yml
```

### `rollback.yml` - Rollback

Reverts to a specific git commit:

```bash
ansible-playbook playbooks/rollback.yml -e "commit=a889c1c"
```

### `setup.yml` - Server Setup Only

Installs system packages, Docker, and configures firewall. No app deployment.

```bash
ansible-playbook playbooks/setup.yml
```

## Roles

### `common` - System Configuration

| Task | Description |
|------|-------------|
| Set timezone | Configures Africa/Cairo timezone |
| System packages | Installs curl, git, htop, jq, etc. |
| Swap | Creates 2GB swap file |
| UFW Firewall | Allows ports 22, 80, 443, 8080 |
| fail2ban | SSH brute-force protection (3 attempts, 2hr ban) |
| Sysctl tuning | Optimizes network/file descriptor limits |
| System limits | Sets nofile/nproc to 65535 |

### `docker` - Docker Engine

| Task | Description |
|------|-------------|
| Install Docker CE | Latest stable from official repo |
| Docker Compose | Plugin (v2) installed with Docker |
| Daemon config | JSON logging (10MB max, 3 files), overlay2 |
| User permissions | Adds app user to docker group |
| Cleanup cron | Weekly prune of unused images/volumes |

### `app` - Application Deployment

| Task | Description |
|------|-------------|
| Clone repository | Pulls from GitHub (main branch) |
| Environment file | Generates .env from template |
| Data directories | Creates persistent storage dirs |
| Docker Compose up | Builds and starts all 8 services |
| Health check | Verifies HTTP 200 on port 80 |
| Backup script | Daily MongoDB backup with 7-day retention |
| Backup cron | Runs at 2:00 AM daily |

### `ssl` - Let's Encrypt

| Task | Description |
|------|-------------|
| Install certbot | Certbot + nginx plugin |
| Obtain certificate | Standalone mode for initial cert |
| Copy to app dir | Places certs in ssl/ directory |
| Renewal hook | Auto-copies certs + restarts nginx |
| Renewal cron | Runs on 1st and 15th of each month |

### `monitoring` - Prometheus & Grafana

| Task | Description |
|------|-------------|
| Prometheus config | 15s scrape interval, 5 targets |
| Alert rules | 6 alerts (CPU, memory, disk, backend, response time, MongoDB) |
| Grafana datasource | Auto-provisions Prometheus connection |
| Dashboard provisioning | File-based dashboard loading |

## Configuration Variables

### Core Variables (`inventory/group_vars/all.yml`)

| Variable | Default | Description |
|----------|---------|-------------|
| `app_name` | `devopsacademy` | Application name |
| `app_user` | `ubuntu` | System user for deployment |
| `domain_name` | `devopsacademy.cloud-stacks.com` | Application domain |
| `git_repo` | GitHub URL | Source repository |
| `git_branch` | `main` | Branch to deploy |

### Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `ssl_enabled` | `true` | Enable Let's Encrypt SSL |
| `monitoring_enabled` | `true` | Enable Prometheus/Grafana |

### Security Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `grafana_admin_user` | `admin` | Grafana admin username |
| `grafana_admin_password` | `devops2026` | Grafana admin password |
| `ssl_email` | `admin@...` | Let's Encrypt email |
| `swap_size` | `2G` | Swap file size |

### Overriding Variables

```bash
# Via command line
ansible-playbook playbooks/site.yml -e "domain_name=myapp.example.com"

# Via extra vars file
ansible-playbook playbooks/site.yml -e "@custom_vars.yml"

# Via environment
export SERVER_IP=1.2.3.4
ansible-playbook playbooks/site.yml
```

## Using with Terraform

After provisioning infrastructure with Terraform, use Ansible to configure it:

```bash
# 1. Provision VM with Terraform
cd terraform
terraform apply
SERVER_IP=$(terraform output -raw public_ip)

# 2. Configure with Ansible
cd ../ansible
export SERVER_IP
ansible-playbook playbooks/site.yml
```

### Dynamic Inventory from Terraform

```bash
# Get IP from terraform output
cd ../terraform
terraform output -raw public_ip > ../ansible/inventory/terraform_ip.txt

# Use in inventory
# Set ansible_host in hosts.yml to use lookup
```

## Tags Reference

Run specific parts of the configuration:

```bash
# Only system setup
ansible-playbook playbooks/site.yml --tags common

# Only Docker installation
ansible-playbook playbooks/site.yml --tags docker

# Only deploy application
ansible-playbook playbooks/site.yml --tags app

# Only SSL certificates
ansible-playbook playbooks/site.yml --tags ssl

# Only monitoring
ansible-playbook playbooks/site.yml --tags monitoring

# Multiple tags
ansible-playbook playbooks/site.yml --tags "docker,app"

# Skip tags
ansible-playbook playbooks/site.yml --skip-tags "ssl,monitoring"
```

## Vault (Secrets Management)

For production, encrypt sensitive variables:

```bash
# Create encrypted vars file
ansible-vault create inventory/group_vars/vault.yml

# Add secrets
vault_grafana_password: "super-secret-password"
vault_jwt_secret: "production-jwt-secret"

# Run with vault
ansible-playbook playbooks/site.yml --ask-vault-pass

# Or use a password file
ansible-playbook playbooks/site.yml --vault-password-file ~/.vault_pass
```

## Troubleshooting

### Connection Issues

```bash
# Test SSH connectivity
ansible all -m ping -vvv

# Check SSH key
ssh -i ~/.ssh/id_rsa ubuntu@YOUR_SERVER_IP

# Verify inventory
ansible-inventory --list
```

### Role Failures

```bash
# Run with verbose output
ansible-playbook playbooks/site.yml -vvv

# Start from a specific task
ansible-playbook playbooks/site.yml --start-at-task="Build Docker images"

# Run in check mode (dry run)
ansible-playbook playbooks/site.yml --check
```

### Docker Issues

```bash
# Check containers on target
ansible all -m shell -a "docker ps -a"

# View container logs
ansible all -m shell -a "docker logs devopsacademy-backend --tail 50"

# Restart all containers
ansible all -m shell -a "cd /home/ubuntu/devopsacademy && docker compose restart"
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Run Ansible Deployment
  uses: dawidd6/action-ansible-playbook@v2
  with:
    playbook: ansible/playbooks/deploy.yml
    directory: ./
    key: ${{ secrets.SSH_PRIVATE_KEY }}
    inventory: |
      [webservers]
      production ansible_host=${{ secrets.SERVER_IP }} ansible_user=ubuntu
    options: |
      --extra-vars "git_branch=${{ github.ref_name }}"
```

### Jenkins Pipeline

```groovy
stage('Deploy with Ansible') {
    steps {
        sh '''
            cd ansible
            ansible-playbook playbooks/deploy.yml \
                -e "git_branch=${BRANCH_NAME}"
        '''
    }
}
```

---

**Last Updated**: June 2026
**Maintained by**: DevOps Academy Team
