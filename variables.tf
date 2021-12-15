variable "azurerm_tenant_id" {
  description = "The Azure AD tenant id for all resources."
  type        = string
}

variable "azurerm_subscription_id" {
  description = "The Azure subscription id for all resources."
  type        = string
}

variable "azurerm_location" {
  description = "The Azure location for all resources."
  type        = string
}

variable "azurerm_failover_location" {
  description = "The Azure failover location for all resources that require it."
  type        = string
}

variable "name_prefix" {
  type = string
}
