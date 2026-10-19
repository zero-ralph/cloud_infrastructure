data "azurerm_resource_group" "mainRG" {
  name = "main"
}

resource "random_string" "acrSuffix" {
  length  = 6
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_container_registry" "acr" {
  name                    = "acr${random_string.acrSuffix.result}"
  resource_group_name     = data.azurerm_resource_group.mainRG.name
  location                = data.azurerm_resource_group.mainRG.location
  sku                     = "Basic"
  admin_enabled           = false
  zone_redundancy_enabled = false
}

resource "azurerm_storage_account" "personalStorageAccount" {
  name                            = "personalstorage${random_string.acrSuffix.result}"
  resource_group_name             = data.azurerm_resource_group.mainRG.name
  location                        = data.azurerm_resource_group.mainRG.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS" # cheapest redundancy
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true # old state versions are only KBs
  }
  access_tier = "Cold"
}

resource "azurerm_storage_container" "personalStorageContainer" {
  name                  = "personalstoragecontainer"
  storage_account_id    = azurerm_storage_account.personalStorageAccount.id
  container_access_type = "private"
}