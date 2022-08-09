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
    name = var.rg4
    location = var.location

}
resource "azurerm_virtual_network" "vnet1" {
    name = var.vnet4
    resource_group_name = azurerm_resource_group.resource2.name
    location = azurerm_resource_group.resource2.location
    address_space = var.node_address_space
}
resource"azurerm_subnet" "subnet1" {
    name = var.subnet4
    resource_group_name = azurerm_resource_group.resource2.name
    virtual_network_name = azurerm_virtual_network.vnet1.name
    address_prefixes = var.node_address_prefix
}

resource "azurerm_network_interface" "networkint2_nic" {
    count = var.node_count
    #name = "${var.resource_prefix}-NIC"
    name = "${var.resource_prefix}-${format("%02d", count.index)}"
    location = azurerm_resource_group.resource2.location
    resource_group_name = azurerm_resource_group.resource2.name
    

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.subnet1.id
        private_ip_address_allocation = "Dynamic"
        
    }
}
  

resource "azurerm_virtual_machine" "vir_machine" {
    count = var.node_count
    name = "${var.resource_prefix}-${format("%02d", count.index)}"
    #name = "${var.resource_prefix}-VM"
    location = azurerm_resource_group.resource2.location
    resource_group_name = azurerm_resource_group.resource2.name
    network_interface_ids = [element(azurerm_network_interface.networkint2_nic.*.id, count.index)]
    vm_size = "Standard_A1_v2"
    delete_os_disk_on_termination = true

    storage_image_reference {
        publisher = "OpenLogic"
        offer = "CentOS"
        sku = "7.5"
        version = "latest"
    }
    storage_os_disk {
        name = "myosdisk-${count.index}"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name = "linuxhost"
        admin_username = "terminator"
        admin_password = "Password@1234"
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags = {
        environment = "Test"
    }
}


resource "azurerm_lb" "azlb2" {
  name                = "azlb2-lb"
  location            = azurerm_resource_group.resource2.location
  resource_group_name = azurerm_resource_group.resource2.name
  sku = "Standard"

  
}

resource "azurerm_lb_backend_address_pool" "azbackendpool" {
  loadbalancer_id = azurerm_lb.azlb2.id
  name            = "azlbpool"
}



