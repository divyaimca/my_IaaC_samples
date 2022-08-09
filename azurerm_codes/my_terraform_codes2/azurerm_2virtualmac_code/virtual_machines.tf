

data "azurerm_resource_group" "myrg1" {
  name = var.rg
}



data "azurerm_virtual_network" "myvnet1" {
  name = var.vnet
  resource_group_name = data.azurerm_resource_group.myrg1.name
}

data "azurerm_subnet" "mysubnet1" {
  name = var.subnet
  resource_group_name = data.azurerm_resource_group.myrg1.name
  virtual_network_name = data.azurerm_virtual_network.myvnet1.name
}

output "existing_rg_details" {
  value = data.azurerm_resource_group.myrg1
  
}

output "rg_id" {
  value = data.azurerm_resource_group.myrg1.id
}

resource "azurerm_public_ip" "pip" {
  name = var.vm_pip
  location = var.location
  resource_group_name = data.azurerm_resource_group.myrg1.name
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "aznetwork" {
    name = data.azurerm_virtual_network.myvnet1.name
    location = var.location
    resource_group_name = var.rg

    ip_configuration {
      name = "testconfiguration1"
      subnet_id = data.azurerm_subnet.mysubnet1.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.pip.id
    }

}
resource "azurerm_virtual_machine" "vm_main" {
    name = var.vm1_name
    location = var.location
    resource_group_name = data.azurerm_resource_group.myrg1.name
    network_interface_ids = [azurerm_network_interface.aznetwork.id]
    vm_size = var.vm_size
    

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
        admin_username = var.username
        admin_password = var.password
      }
      os_profile_linux_config {
        disable_password_authentication = false
      }
    tags = {
        environment = "virtualmachine"
    }
}