# Terraform - Dev Environment
# Replace with your actual Terraform configuration
# This file is scanned by Checkov (CIS Benchmark) in ci-security.yml

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  # Configure remote state - update with your backend
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstate"
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

# =============================================
# VARIABLES - Override in terraform.tfvars
# =============================================

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "myproject"
}

# =============================================
# RESOURCE GROUP
# =============================================

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = {
    environment  = var.environment
    project      = var.project_name
    managed-by   = "terraform"
    # CIS Azure: All resources should be tagged
  }
}

# =============================================
# MODULES - Add your modules here
# See terraform/modules/ for available modules
# =============================================

# Example: AKS Cluster
# module "aks" {
#   source = "../../modules/aks"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = var.location
#   environment         = var.environment
#   project_name        = var.project_name
# }

# Example: Key Vault
# module "key_vault" {
#   source = "../../modules/key-vault"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = var.location
#   environment         = var.environment
#   project_name        = var.project_name
# }
