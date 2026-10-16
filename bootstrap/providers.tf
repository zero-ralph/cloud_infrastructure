terraform {
    required_version = ">=1.6"

    required_providers {
        azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
        azuread = { source = "hashicorp/azuread", version = "~> 3.0" }
        random  = { source = "hashicorp/random", version = "~> 3.6" }
    }
}

provider "azurerm" {
    features {}
    subscription_id = var.subscription_id

    # Only register what bootstrap needs; the default set includes slow
    # providers (e.g. Microsoft.AVS) that can time out on a fresh subscription.
    resource_provider_registrations = "none"
    resource_providers_to_register = [
        "Microsoft.Authorization",
        "Microsoft.Consumption",
        "Microsoft.Resources",
        "Microsoft.Storage",
    ]
}

provider "azuread" {}