output "AZURE_CLIENT_ID"         { value = azuread_application.githubApplication.client_id }
output "AZURE_TENANT_ID"         { value = data.azurerm_subscription.current.tenant_id }
output "AZURE_SUBSCRIPTION_ID"   { value = data.azurerm_subscription.current.subscription_id }
output "tfstate_storage_account" { value = azurerm_storage_account.terraformStateSA.name }