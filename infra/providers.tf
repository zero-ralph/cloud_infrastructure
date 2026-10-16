terraform {
  required_version = ">=1.6"

  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
    random  = { source = "hashicorp/random", version = "~> 3.6" }
  }

  backend "azurerm" {
    resource_group_name = "main"
    container_name      = "terraformstate"
    key                 = "infra.tfstate"
    use_oidc            = true
    use_azuread_auth    = true
  }
}

provider "azurerm" {
  features {}
  # The CI service principal is only Contributor on the "main" RG, so it
  # can't register providers at subscription level. Register them once by hand.
  resource_provider_registrations = "none"
}