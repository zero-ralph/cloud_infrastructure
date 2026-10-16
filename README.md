# Cloud Infrastructure

Infrastructure as Code for our cloud environment.

## Stack

- **Cloud provider:** [Microsoft Azure](https://azure.microsoft.com/)
- **IaC tool:** [Terraform](https://www.terraform.io/)

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- Access to the target Azure subscription

## Getting Started

```bash
# Sign in to Azure
az login
az account set --subscription "<subscription-id>"

# Initialise and apply
terraform init
terraform planhow
terraform apply
```
