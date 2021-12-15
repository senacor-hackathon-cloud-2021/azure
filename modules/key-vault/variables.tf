variable "azurerm_tenant_id" {
  description = "The Azure AD tenant id for all resources."
  type        = string
}

variable "azurerm_location" {
  description = "Azure location to build the resources in."
  type        = string
}

variable "name_prefix" {
  description = "Common prefix for for all resources."
  type        = string
}

variable "name" {
  description = "Name for the deployment vault."
  type        = string
}

variable "secret_reader_object_ids" {
  description = "List of object IDs (Users, Groups, SP, MSI) that are allowed to read key vault secrets. Esp. required for terraform users to execute 'plan'."
  type        = list(string)
  default     = []
}

variable "random_secret_names" {
  description = "List of names for random passwords / secrets to create, for demo purposes."
  type        = list(string)
  default     = []
}
