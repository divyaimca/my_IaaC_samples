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
  name     = "LoadBalancerRG"
  location = "East Asia"
}

resource "azurerm_public_ip" "publicip1" {
  name                = "PublicIP"
  location            = azurerm_resource_group.resogrp.location
  resource_group_name = azurerm_resource_group.resogrp.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "az_lb" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.resogrp.location
  resource_group_name = azurerm_resource_group.resogrp.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.publicip1.id
  }
}
resource "azurerm_lb_backend_address_pool" "lbbackend" {
  loadbalancer_id = data.azurerm_lb.azlb.id
  name            = "BackEndAddressPool"
}
resource "azurerm_virtual_network" "vnet1" {
    name = "var.vnet-network"
    address_space = [ "10.0.0.0/16" ]
    location = azurerm_resource_group.resogrp.location
    resource_group_name = azurerm_resource_group.resogrp.name

}
data "azurerm_virtual_network" "virnet" {
  name                = "virnet-network"
  resource_group_name = "resogrp-resources"
}

data "azurerm_lb" "azlb" {
  name                = "azlb-lb"
  resource_group_name = "resogrp-resources"
}


data"azurerm_lb_backend_address_pool" "azlbaddress" {
  name            = "azadress1"
  loadbalancer_id = data.azurerm_lb.azlb.id
}

resource "azurerm_lb_backend_address_pool_address" "azbackpool" {
  name                    = "azbackpool1"
  backend_address_pool_id = data.azurerm_lb_backend_address_pool.azlbaddress.id
  virtual_network_id      = data.azurerm_virtual_network.virnet.id
  ip_address              = "10.0.0.1"
}
resource "azurerm_lb_nat_pool" "aznatpool" {
  resource_group_name            = azurerm_resource_group.resogrp.name
  loadbalancer_id                = data.azurerm_lb.azlb.id
  name                           = "SampleApplicationPool"
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
}
resource "azurerm_lb_nat_rule" "aznat" {
  resource_group_name            = azurerm_resource_group.resogrp.name
  loadbalancer_id                = data.azurerm_lb.azlb.id
  name                           = "RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
}
resource "azurerm_lb_outbound_rule" "azoutbound" {
  loadbalancer_id         = data.azurerm_virtual_network.virnet
  name                    = "OutboundRule"
  protocol                = "Tcp"
  backend_address_pool_id = data.azurerm_lb_backend_address_pool.azlbaddress.id

  frontend_ip_configuration {
    name = "PublicIPAddress"
  }
}
resource "azurerm_lb_probe" "azlbprobe" {
  loadbalancer_id = data.azurerm_lb.azlb.id
  name            = "ssh-running-probe"
  port            = 22
}
resource "azurerm_lb_rule" "azlbrule" {
  loadbalancer_id                = data.azurerm_lb.azlb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
}