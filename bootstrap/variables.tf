variable "subscription_id" {
  description = "The subscription ID to use for the Azure resources."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
  default     = "SouthEast Asia"
}

variable "budget_emails" {
  description = "List of email addresses to notify when budget thresholds are exceeded."
  type        = list(string)
}