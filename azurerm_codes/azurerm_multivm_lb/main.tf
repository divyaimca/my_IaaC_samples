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

resource "azurerm_resource_group" "az_resources" {
  name     = "azure-resources"
  location = "East Asia"
}

resource "azurerm_virtual_network" "az_network" {
  name                = "azure-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.az_resources.location
  resource_group_name = azurerm_resource_group.az_resources.name
}

resource "azurerm_subnet" "az_subnet" {
  name                 = "azure_subnet"
  resource_group_name  = azurerm_resource_group.az_resources.name
  virtual_network_name = azurerm_virtual_network.az_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "az_nic" {
  count               = 2
  name                = "azure-NIC-${count.index}"
  location            = azurerm_resource_group.az_resources.location
  resource_group_name = azurerm_resource_group.az_resources.name

  ip_configuration {
    name                          = "nic_config_host_${count.index}"
    subnet_id                     = azurerm_subnet.az_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.az_pip[count.index].id
  }
}

resource "azurerm_ssh_public_key" "az_pub_key" {
  name                = "az_pkey"
  resource_group_name = azurerm_resource_group.az_resources.name
  location            = azurerm_resource_group.az_resources.location
  public_key          = file("~/.ssh/id_rsa.pub")
}
resource "azurerm_public_ip" "az_pip" {
  count               = 2
  name                = "azure-vm-nic-0${count.index}"
  resource_group_name = azurerm_resource_group.az_resources.name
  location            = azurerm_resource_group.az_resources.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_security_group" "az_network_security" {
  name                = "azure-security-group1"
  location            = azurerm_resource_group.az_resources.location
  resource_group_name = azurerm_resource_group.az_resources.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["22","80"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}



resource "azurerm_linux_virtual_machine" "vms" {
  name                = "azure-VM-${count.index}"
  count               = 2
  resource_group_name = azurerm_resource_group.az_resources.name
  location            = azurerm_resource_group.az_resources.location
  size                = "Standard_ds1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    element(azurerm_network_interface.az_nic.*.id, count.index)
 ]


 admin_ssh_key {
    username   = "adminuser"
    public_key = azurerm_ssh_public_key.az_pub_key.public_key
 }
  
 os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_network_interface_security_group_association" "az_association" {
    count = 2
    network_interface_id      = element(azurerm_network_interface.az_nic.*.id, count.index)
    network_security_group_id = azurerm_network_security_group.az_network_security.id
}

resource "null_resource" "apache2" {
  count = 2
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get -y upgrade",
      "sudo apt install apache2 -y",
      "sudo systemctl stop apache2",
      "sudo chmod 777 /var/www/html/index.html",
      "sudo echo `hostname` > /var/www/html/index.html",
      "sudo echo `hostname -I` >> /var/www/html/index.html",
      "sudo systemctl restart apache2",
      "sudo systemctl status apache2 --no-pager",
    ]
  connection {
        host = element(azurerm_linux_virtual_machine.vms.*.public_ip_address, count.index)
        user = "adminuser"
        type = "ssh"
        private_key = file("~/.ssh/id_rsa")
        timeout = "10m"
        agent = false
    }
  }

}


resource "azurerm_public_ip" "lb_public_ip" {
  name                = "lb_pip"
  location            = azurerm_resource_group.az_resources.location
  resource_group_name = azurerm_resource_group.az_resources.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "azure_lb" {
  name                = "azure_test_lb"
  location            = azurerm_resource_group.az_resources.location
  resource_group_name = azurerm_resource_group.az_resources.name
  sku = "Standard"  
  frontend_ip_configuration {
    name                 = "lb_frontend_pip"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "az_backend_pool" {
  loadbalancer_id = azurerm_lb.azure_lb.id
  name            = "azure_lb_pool"
}

resource "azurerm_lb_probe" "az_lb_probe" {
  loadbalancer_id     = azurerm_lb.azure_lb.id
  name                = "classiclb"
  port                = 80
  interval_in_seconds = 10
  number_of_probes    = 3
  protocol            = "Tcp"
}

resource "azurerm_lb_rule" "az_lb_rule" {
  loadbalancer_id                = azurerm_lb.azure_lb.id
  name                           = "classiclb"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb_frontend_pip"
  probe_id                       = azurerm_lb_probe.az_lb_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.az_backend_pool.id]
}


resource "azurerm_network_interface_backend_address_pool_association" "az_lb_association" {
  count = 2
  network_interface_id    = element(azurerm_network_interface.az_nic.*.id, count.index)
  ip_configuration_name   = "nic_config_host_${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.az_backend_pool.id
}

output "vm_public_ip" {
  value = azurerm_public_ip.az_pip.*.ip_address
}

output "loabbalancer_frontend_public_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}