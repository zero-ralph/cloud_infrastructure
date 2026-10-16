data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

# Random
resource "random_string" "storageAccountSuffix" {
  length  = 6
  upper   = false
  numeric  = true
  special = false
}


# Resources
resource "azurerm_resource_group" "mainRG" {
  name     = "main"
  location = var.location
}

resource "azurerm_storage_account" "terraformStateSA" {
  name                     = "terraformstate${random_string.storageAccountSuffix.result}"
  resource_group_name             = azurerm_resource_group.mainRG.name
  location                        = azurerm_resource_group.mainRG.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"   # cheapest redundancy
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true   # old state versions are only KBs
  }

}

resource "azurerm_storage_container" "terraformStateSC" {
  name                  = "terraformstate"
  storage_account_id = azurerm_storage_account.terraformStateSA.id
  container_access_type = "private"
}


# Service Principal for GitHub Actions
resource "azuread_application" "githubApplication" {
    display_name = "sp-github"
	owners = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "githubServicePrincipal" {
	client_id = azuread_application.githubApplication.client_id
	owners = [data.azurerm_client_config.current.object_id]
}

resource "azuread_application_federated_identity_credential" "githubFederatedIdentity" {
	application_id = azuread_application.githubApplication.id
	display_name   = "github-cloud-infrastructure"
	issuer         = "https://token.actions.githubusercontent.com"
	subject		   = "repo:zero-ralph/cloud_infrastructure:ref:refs/heads/main"
	audiences      = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "githubRoleAssignment" {
  principal_id   = azuread_service_principal.githubServicePrincipal.object_id
  role_definition_name = "Contributor"
  scope          = azurerm_resource_group.mainRG.id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "githubStorageBlobDataContributor" {
  principal_id   = azuread_service_principal.githubServicePrincipal.object_id
  principal_type       = "ServicePrincipal"
  role_definition_name = "Storage Blob Data Contributor"
  scope          = azurerm_storage_account.terraformStateSA.id
}


# Cost Guardrail: Limit the number of resources in the subscription to 10
resource "azurerm_consumption_budget_subscription" "costGuardrail" {
	name = "budget-monitor"
	subscription_id = data.azurerm_subscription.current.id
	amount = 20
	time_grain = "Monthly"

	time_period {
    	start_date = formatdate("YYYY-MM-01'T'00:00:00'Z'", timestamp())
  	}

	  # Email when actual spend passes 50%
  	notification {
	    enabled        = true
	    threshold      = 50
	    operator       = "GreaterThan"
	    threshold_type = "Actual"
	    contact_emails = var.budget_emails
  	}

  	# Email when Azure forecasts you'll pass 100% this month
  	notification {
	    enabled        = true
	    threshold      = 80
	    operator       = "GreaterThan"
	    threshold_type = "Forecasted"
	    contact_emails = var.budget_emails
  	}

  	lifecycle {
	    ignore_changes = [time_period]   # start date is set once
  	}
}