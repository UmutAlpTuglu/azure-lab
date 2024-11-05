# A provider is a plugin that interacts with the various APIs of cloud providers required to create, update, and delete various resources.
# The AzureRM Terraform Provider allows managing resources within Azure Resource Manager

terraform {
  required_version = ">=1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}