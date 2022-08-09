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
  name     = "resource_group_1"
  location = "East Asia"
}

resource "azurerm_storage_account" "storage_1" {
  name                     = "azstorage"
  resource_group_name      = azurerm_resource_group.resource1.name
  location                 = "East Asia"
  account_tier             = "Standard"
  account_replication_type = "GRS"



  tags = {
    environment = "storage"
  }
}

resource "azurerm_mysql_server" "mysql1" {
  name                              = "mysqldb1"
  location                          = "East Asia"
  resource_group_name               = azurerm_resource_group.resource1.name
  administrator_login              = "mysqldb"
  administrator_login_password     = "abcd@1234"
  sku_name                          = "GP_Gen5_2"
  storage_mb                        = 5120
  version                           = "5.7"
  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = true
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}
  resource "azurerm_mysql_database" "mysqldb1" {
    name                = "mysqldb_1"
    resource_group_name = azurerm_resource_group.resource1.name
    server_name         = azurerm_mysql_server.mysql1.name
    charset             = "utf8"
    collation          = "utf8_unicode_ci"
    
  
   
  }
  resource "azurerm_network_security_group" "vnet_1" {
    name                = "vnet_security"
    location            = "East Asia"
    resource_group_name = azurerm_resource_group.resource1.name
  }


  resource "azurerm_virtual_network" "vnet_2" {
    name                = "vnet_network"
    location            = "East Asia"
    resource_group_name = azurerm_resource_group.resource1.name
    address_space       = ["10.0.0.0/16"]
    dns_servers         = ["10.0.0.4", "10.0.0.5"]

    subnet {
      name           = "subnet1"
      address_prefix = "10.0.1.0/24"
    }

    subnet {
      name           = "subnet2"
      address_prefix = "10.0.2.0/24"
      security_group = azurerm_network_security_group.vnet_1.name
    }

    tags = {
      environment = "vir network"
    }
  }








