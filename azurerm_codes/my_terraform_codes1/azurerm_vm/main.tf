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
    name = "var.reso-resources"
    location =  "East Asia"
  
}
resource "azurerm_virtual_network" "vnet1" {
    name = "var.vnet-network"
    address_space = [ "10.0.0.0/16" ]
    location = azurerm_resource_group.resource1.location
    resource_group_name = azurerm_resource_group.resource1.name
  
}
resource "azurerm_subnet" "virsubnet" {
    name = "var.subnet-nic"
    resource_group_name = azurerm_resource_group.resource1.name
    virtual_network_name = azurerm_virtual_network.vnet1.name
    address_prefixes = [ "10.0.2.0/24" ]
  
}
resource "azurerm_network_interface" "aznetwork" {
    name = "var.aznetwork1-nic"
    location = azurerm_resource_group.resource1.location
    resource_group_name = azurerm_resource_group.resource1.name

    ip_configuration {
      name = "testconfiguration1"
      subnet_id = azurerm_subnet.virsubnet.id
      private_ip_address_allocation = "Dynamic"
    }
}
resource "azurerm_virtual_machine" "vm_main" {
    name = "azurevm"
    location = azurerm_resource_group.resource1.location
    resource_group_name = azurerm_resource_group.resource1.name
    network_interface_ids = [azurerm_network_interface.aznetwork.id]
    vm_size = "Standard_DS1_v2"

storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
tags = {
    environment = "virtualmachine"
}
}