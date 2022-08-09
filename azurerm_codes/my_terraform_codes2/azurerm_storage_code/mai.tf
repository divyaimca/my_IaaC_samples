terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.10.0"
    }
  }

  # required_version = ">= 1.1.0"
}


provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "resogrp" {
  name     = "Resogrp-resources"
  location = "East Asia"
}

resource "azurerm_storage_account" "azstorage" {
  name                     = "azstoragename"
  resource_group_name      = azurerm_resource_group.resogrp.name
  location                 = azurerm_resource_group.resogrp.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}

