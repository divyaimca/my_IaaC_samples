provider "azurerm" {
  features {}

  subscription_id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_id       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  client_secret   = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  tenant_id       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}

resource "azurerm_resource_group" "rg" {
  name     = "mywinvm-rg" 
  location = "westus"

 
}

resource "azurerm_virtual_network" "vnet" {
  name                = "mywinvm_Network"
  address_space       = ["10.1.0.0/16"]
  location            = "westus"
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    env        = "cicd"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "mywinvm_Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.1.1.0/24"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "mywinvm_nsg"
  location            = "westus"
  resource_group_name = azurerm_resource_group.rg.name
  
  security_rule {
    name                       = "Allow_RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "Allow_WinRM"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    env        = "cicd"
  }
}

resource "azurerm_subnet_network_security_group_association" "sg_associate" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "public_ip" {
  name                = "win_pub_ip"
  location            = "westus"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = "mywinrmvm1"

  tags = {
    env        = "cicd"
  }
}


resource "azurerm_network_interface" "win_ip" {
  name                = "win_ip"
  location            = "westus"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "win_ipconf"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = "10.1.1.10"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = {
   env        = "cicd"
  }
}

resource "azurerm_virtual_machine" "win" {
  name                  = "mywinrmvm1"
  location              = "westus"
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.win_ip.id]
  vm_size               = "Standard_F2"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "mywinrmvm1"
    admin_username = "adminuser"
    admin_password = "p@$$w0rd123!"
    custom_data    = file("./files/winrm.ps1")
  }

  os_profile_windows_config {
    provision_vm_agent = true
    winrm {
      protocol = "http"
    }
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>p@$$w0rd123!</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>adminuser</Username></AutoLogon>"
    }

    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = file("./files/FirstLogonCommands.xml")
    }
  }

  tags = {
    env        = "cicd"
  }

  connection {
    host     = azurerm_public_ip.public_ip.fqdn
    type     = "winrm"
    port     = 5985
    https    = false
    timeout  = "10m"
    user     = "adminuser"
    password = "p@$$w0rd123!"
  }

  provisioner "file" {
    source      = "files/"
    destination = "c:/terraform/"
  }

  provisioner "remote-exec" {
    inline = [
      "PowerShell.exe -ExecutionPolicy Bypass c:\\terraform\\config.ps1",
      "PowerShell.exe -ExecutionPolicy Bypass c:\\terraform\\python.ps1",


    ]
  }

}

output "public_fqdn" {
  value = azurerm_public_ip.public_ip.fqdn
}

output "public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

