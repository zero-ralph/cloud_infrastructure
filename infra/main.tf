data "azurerm_resource_group" "mainRG" {
  name = "main"
}

data "azuread_application" "github" {
  client_id = "5b9e6d49-a7ae-4433-966b-1b9c441a8850"
}

data "azuread_service_principal" "github" {
  client_id = data.azuread_application.github.client_id
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

# Let Github action login as sp-github 
resource "azuread_application_federated_identity_credential" "website" {
  application_id = data.azuread_application.github.id
  display_name = "github-website"
  issuer = "https://token.actions.githubusercontent.com"
  subject = "repo:zero-ralph@17931218/website@1429953392:ref:refs/heads/main"
  audiences = ["api://AzureADTokenExchange"]
}

# Allow it to push in ACR 
resource "azurerm_role_assignment" "website_acr_push" {
  scope = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id = data.azuread_service_principal.github.object_id
}