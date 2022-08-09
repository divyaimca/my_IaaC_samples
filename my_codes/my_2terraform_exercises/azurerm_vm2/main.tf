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
resource "azurerm_resource_group" "resource2" {
    name = "var.2reso-resources"
    location =  "East Asia"
  
}
resource "azurerm_virtual_network" "vnet2" {
    name = "var.2vnet-network"
    address_space = [ "10.0.0.0/16" ]
    location = azurerm_resource_group.resource2.location
    resource_group_name = azurerm_resource_group.resource2.name
  
}
resource "azurerm_subnet" "virsubnet2" {
    name = "var.subnet-nic"
    resource_group_name = azurerm_resource_group.resource2.name
    virtual_network_name = azurerm_virtual_network.vnet2.name
    address_prefixes = [ "10.0.2.0/24" ]
  
}
resource "azurerm_network_interface" "aznetwork2" {
    name = "var.aznetwork2-nic"
    location = azurerm_resource_group.resource2.location
    resource_group_name = azurerm_resource_group.resource2.name

    ip_configuration {
      name = "testconfiguration2"
      subnet_id = azurerm_subnet.virsubnet2.id
      private_ip_address_allocation = "Dynamic"
    }
}
resource "azurerm_virtual_machine" "vm_main2" {
    name = "azurevm2"
    location = azurerm_resource_group.resource2.location
    resource_group_name = azurerm_resource_group.resource2.name
    network_interface_ids = [azurerm_network_interface.aznetwork2.id]
    vm_size = "Standard_DS1_v2"

storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin2"
    admin_password = "password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
tags = {
    environment = "virtualmachine2"
}
}