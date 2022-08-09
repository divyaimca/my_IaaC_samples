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
  name     = var.rg
  location = var.location
}

resource "azurerm_mysql_server" "mysql" {
  name                = var.azmysql
  location            = azurerm_resource_group.resource2.location
  resource_group_name = azurerm_resource_group.resource2.name

  administrator_login          = "mysqladminum"
  administrator_login_password = "mydb@1234"

  sku_name   = "GP_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = true
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_mysql_database" "mysqldb" {
  name                = var.mysqldb
  resource_group_name = azurerm_resource_group.resource2.name
  server_name         = azurerm_mysql_server.mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}