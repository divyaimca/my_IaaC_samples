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
    name = "resource_grp1-resources"
    location = "East Asia"
  
}
resource "azurerm_virtual_network" "vnet_nic1" {
    name = "vnet_nic1-network"
    address_space = ["8.0.0.0/6"]
    location = azurerm_resource_group.resource1.location
    resource_group_name = azurerm_resource_group.resource1.name
  
}
resource "azurerm_subnet" "subnet1" {
    name = "subnet1"
    resource_group_name = azurerm_resource_group.resource1.name
    virtual_network_name = azurerm_virtual_network.vnet_nic1.name
    address_prefixes = ["10.0.2.0/24"]
  
}
resource "azurerm_network_interface" "networkint1" {
  name = "net.interface-nic"
  location = azurerm_resource_group.resource1.location
  resource_group_name = azurerm_resource_group.resource1.name
  ip_configuration {
    name = "testipconfig1"
    subnet_id = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_virtual_machine" "vir1" {
  name = "vir.mac1-vm"
  resource_group_name = azurerm_resource_group.resource1.name
  location = azurerm_resource_group.resource1.location
  network_interface_ids = [azurerm_network_interface.networkint1.id]
  vm_size = "standard_DS1_v2"

  

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
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "vir.machine"
  }

}


  
  
  

  
    
    
  

