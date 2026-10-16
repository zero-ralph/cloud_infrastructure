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
  name                     = "acr${random_string.acrSuffix.result}"
  resource_group_name      = data.azurerm_resource_group.mainRG.name
  location                 = data.azurerm_resource_group.mainRG.location
  sku                      = "Basic"
  admin_enabled            = false
  zone_redundancy_enabled  = false
}