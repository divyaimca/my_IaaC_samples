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
    name = var.rg4
    
    
  
}
data "azurerm_virtual_network" "vnet1" {
    name = var.vnet4
    resource_group_name = data.azurerm_resource_group.resource2.name
}
data "azurerm_subnet" "subnet1" {
    name = var.subnet4
    resource_group_name = data.azurerm_resource_group.resource2.name
    virtual_network_name = data.azurerm_virtual_network.vnet1.name
}
resource "azurerm_public_ip" "azpip3" {
  name                    = var.vm4_pip
  location                = data.azurerm_resource_group.resource2.location
  resource_group_name     = data.azurerm_resource_group.resource2.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "vm"
  }
}
resource "azurerm_network_interface" "networkint3" {
  name = var.vm4_nic
  location = data.azurerm_resource_group.resource2.location
  resource_group_name = data.azurerm_resource_group.resource2.name
  ip_configuration {
    name = "testipconfig4"
    subnet_id = data.azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_virtual_machine" "vir2" {
  name = var.vm4_name
  resource_group_name = data.azurerm_resource_group.resource2.name
  location = data.azurerm_resource_group.resource2.location
  network_interface_ids = [azurerm_network_interface.networkint3.id]
  vm_size = var.vm4_size

  

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
    computer_name  = "myvmmac"
    admin_username = var.username
    admin_password = var.password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "vir.machine"
  }

}



