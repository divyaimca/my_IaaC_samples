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
resource "azurerm_resource_group" "resogrp2" {
  name     = "LoadBalancerRG2"
  location = "East Asia"
}

resource "azurerm_public_ip" "publicip2" {
  name                = "PublicIP2"
  location            = azurerm_resource_group.resogrp2.location
  resource_group_name = azurerm_resource_group.resogrp2.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "az_lb2" {
  name                = "TestLoadBalancer2"
  location            = azurerm_resource_group.resogrp2.location
  resource_group_name = azurerm_resource_group.resogrp2.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress2"
    public_ip_address_id = azurerm_public_ip.publicip2.id
  }
}
resource "azurerm_lb_backend_address_pool" "lbbackend2" {
  loadbalancer_id = azurerm_lb.az_lb2.id
  name            = "BackEndAddressPool2"
}
resource "azurerm_virtual_network" "vnet2" {
    name = "var.vnet-network"
    address_space = [ "10.0.0.0/16" ]
    location = azurerm_resource_group.resogrp2.location
    resource_group_name = azurerm_resource_group.resogrp2.name

}
data "azurerm_virtual_network" "virnet2" {
  name                = "vir.net-network2"
  resource_group_name = "azurerm_resource_group.resogrp2-resources"
}

data "azurerm_lb" "azlb2" {
  name                = "az.lb-lb2"
  resource_group_name = "azurerm_resource_group.resogrp2-resources"
}



data"azurerm_lb_backend_address_pool" "azlbaddress2" {
  name            = "azadress2"
  loadbalancer_id = data.azurerm_lb.azlbbalance2.id
}

resource "azurerm_lb_backend_address_pool_address" "azbackpool2" {
  name                    = "azbackpool2"
  backend_address_pool_id = data.azurerm_lb_backend_address_pool.azlbaddress2.id
  virtual_network_id      = azurerm_virtual_network.azvirnet2
  ip_address              = "10.0.0.1"
}
resource "azurerm_lb_nat_pool" "aznatpool2" {
  resource_group_name            = azurerm_resource_group.resogrp2.name
  loadbalancer_id                = data.azurerm_lb.azlbbalance2.id
  name                           = "SampleApplicationPool2"
  protocol                       = "Tcp"
  frontend_port_start            = 80
  frontend_port_end              = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress2"
}
resource "azurerm_lb_nat_rule" "aznat" {
  resource_group_name            = azurerm_resource_group.resogrp2.name
  loadbalancer_id                = data.azurerm_lb.azlbbalance2.id
  name                           = "RDPAccess2"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress2"
}
resource "azurerm_lb_outbound_rule" "azoutbound2" {
  loadbalancer_id         = data.azurerm_virtual_network2.virnet
  name                    = "OutboundRule"
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.azlbaddress2.id

  frontend_ip_configuration {
    name = "PublicIPAddress2"
  }
}
resource "azurerm_lb_probe" "azlbprobe2" {
  loadbalancer_id = data.azurerm_lb.azlbbalance2.id
  name            = "ssh-running-probe2"
  port            = 22
}
resource "azurerm_lb_rule" "azlbrule2" {
  loadbalancer_id                = data.azurerm_lb.azlbbalance2.id
  name                           = "LBRule2"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress2"
}