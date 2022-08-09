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
data "azurerm_resource_group" "resource2" {
  name     = var.rg4
}

resource "azurerm_public_ip" "azpip" {
  name                = var.az_pip
  location            = data.azurerm_resource_group.resource2.location
  resource_group_name = data.azurerm_resource_group.resource2.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "azlb" {
  name                = var.az_lb
  location            = data.azurerm_resource_group.resource2.location
  resource_group_name = data.azurerm_resource_group.resource2.name

  frontend_ip_configuration {
    name                 = "lbfrontend"
    public_ip_address_id = azurerm_public_ip.azpip.id
  }
}
resource "azurerm_lb_probe" "azlbprobe" {
  loadbalancer_id = azurerm_lb.azlb.id
  name            = "ssh-running-probe"
  port            = 22
}
resource "azurerm_lb_backend_address_pool" "azlbbackend" {
  loadbalancer_id = azurerm_lb.azlb.id
  name            = var.az_lb_backend
}

