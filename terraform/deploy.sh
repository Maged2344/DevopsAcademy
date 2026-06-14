#!/bin/bash

################################################################################
# Terraform Quick Start Script
# 
# This script provides quick deployment steps for the DevOps Academy
# infrastructure across different cloud providers.
#
# Usage: ./deploy.sh <provider>
# Example: ./deploy.sh aws
################################################################################

set -e

PROVIDER=${1:-aws}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Validate provider
validate_provider() {
    case "$PROVIDER" in
        aws|gcp|azure|alibaba|oracle)
            return 0
            ;;
        *)
            print_error "Invalid provider: $PROVIDER"
            echo "Valid providers: aws, gcp, azure, alibaba, oracle"
            exit 1
            ;;
    esac
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform not found. Please install Terraform v1.0+"
        exit 1
    fi
    print_success "Terraform $(terraform version -json | jq -r .terraform_version)"
    
    # Check cloud CLI
    case "$PROVIDER" in
        aws)
            if ! command -v aws &> /dev/null; then
                print_error "AWS CLI not found. Please install AWS CLI v2"
                exit 1
            fi
            print_success "AWS CLI $(aws --version)"
            ;;
        gcp)
            if ! command -v gcloud &> /dev/null; then
                print_error "Google Cloud SDK not found. Please install gcloud"
                exit 1
            fi
            print_success "Google Cloud SDK $(gcloud version | head -1)"
            ;;
        azure)
            if ! command -v az &> /dev/null; then
                print_error "Azure CLI not found. Please install Azure CLI"
                exit 1
            fi
            print_success "Azure CLI $(az version | jq -r '."azure-cli"')"
            ;;
    esac
    
    echo ""
}

# Check credentials
check_credentials() {
    print_header "Checking Cloud Credentials"
    
    case "$PROVIDER" in
        aws)
            if [ -z "$AWS_ACCESS_KEY_ID" ] && [ ! -f ~/.aws/credentials ]; then
                print_warning "AWS credentials not configured"
                echo "Run: aws configure"
                exit 1
            fi
            print_success "AWS credentials found"
            ;;
        gcp)
            if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
                print_warning "GCP credentials not configured"
                echo "Run: gcloud auth application-default login"
                exit 1
            fi
            print_success "GCP credentials found"
            ;;
        azure)
            if ! az account show &> /dev/null; then
                print_warning "Azure credentials not configured"
                echo "Run: az login"
                exit 1
            fi
            print_success "Azure credentials configured"
            ;;
    esac
    
    echo ""
}

# Initialize Terraform
init_terraform() {
    print_header "Initializing Terraform"
    
    cd "$SCRIPT_DIR"
    terraform init
    
    print_success "Terraform initialized"
    echo ""
}

# Prepare configuration
prepare_config() {
    print_header "Preparing Configuration"
    
    ENV_FILE="environments/${PROVIDER}.tfvars"
    
    if [ ! -f "$ENV_FILE" ]; then
        print_error "Environment file not found: $ENV_FILE"
        exit 1
    fi
    
    # Copy to terraform.tfvars if not exists
    if [ ! -f "terraform.tfvars" ]; then
        cp "$ENV_FILE" terraform.tfvars
        print_success "Created terraform.tfvars from $ENV_FILE"
        print_info "Please review and customize terraform.tfvars before proceeding"
    else
        print_info "terraform.tfvars already exists, using existing configuration"
    fi
    
    echo ""
}

# Validate configuration
validate_config() {
    print_header "Validating Configuration"
    
    cd "$SCRIPT_DIR"
    terraform validate
    
    print_success "Configuration is valid"
    echo ""
}

# Show plan
show_plan() {
    print_header "Terraform Plan"
    
    cd "$SCRIPT_DIR"
    terraform plan -out=tfplan
    
    echo ""
}

# Ask for confirmation
confirm_apply() {
    read -p "Do you want to apply these changes? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_error "Deployment cancelled"
        exit 1
    fi
}

# Apply configuration
apply_terraform() {
    print_header "Applying Configuration"
    
    cd "$SCRIPT_DIR"
    terraform apply tfplan
    
    print_success "Infrastructure deployed successfully"
    echo ""
}

# Show outputs
show_outputs() {
    print_header "Deployment Outputs"
    
    cd "$SCRIPT_DIR"
    terraform output -json | jq '.'
    
    echo ""
}

# Main execution
main() {
    validate_provider
    
    echo ""
    print_header "DevOps Academy Terraform Deployment"
    print_info "Provider: $PROVIDER"
    echo ""
    
    check_prerequisites
    check_credentials
    init_terraform
    prepare_config
    validate_config
    show_plan
    
    confirm_apply
    
    apply_terraform
    show_outputs
    
    print_header "Deployment Complete!"
    echo ""
    print_info "SSH Command:"
    echo "  ssh -i <your-key> $(cd $SCRIPT_DIR && terraform output -raw instance_username)@$(cd $SCRIPT_DIR && terraform output -raw public_ip)"
    echo ""
    print_info "View deployment status: terraform output -json"
    echo ""
}

# Run main function
main
