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

resource "azurerm_resource_group" "resource1" {
    name = var.rg
    location =  var.location
  
}
resource "azurerm_virtual_network" "vnet1" {
    name = var.vnet
    address_space = [ "10.0.0.0/16" ]
    location = var.location
    resource_group_name = azurerm_resource_group.resource1.name
  
}
resource "azurerm_subnet" "virsubnet" {
    name = var.subnet
    resource_group_name = azurerm_resource_group.resource1.name
    virtual_network_name = azurerm_virtual_network.vnet1.name
    address_prefixes = [ "10.0.2.0/24" ]
  
}