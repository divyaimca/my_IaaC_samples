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
resource "azurerm_resource_group" "resogrp" {
  name     = "Resogrp-resources"
  location = "East Asia"
}

resource "azurerm_storage_account" "azstorage" {
  name                     = "azstoragename"
  resource_group_name      = azurerm_resource_group.resogrp.name
  location                 = azurerm_resource_group.resogrp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_mssql_server" "azmysql" {
  name                         = "azmysql-sqlserver"
  resource_group_name          = azurerm_resource_group.resogrp.name
  location                     = azurerm_resource_group.resogrp.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_mssql_database" "test" {
  name           = "acctest-db-d"
  server_id      = azurerm_mssql_server.azmysql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "S0"
  zone_redundant = true

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.azstorage.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.azstorage.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }


  tags = {
    foo = "bar"
  }

}