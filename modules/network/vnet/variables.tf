variable "name_prefix" {
  description = "Common prefix to add to all resource names."
  type        = string
}

variable "name" {
  description = "Name of the Vnet, prefixed by name_prefix."
  type        = string
}

variable "azurerm_location" {
  description = "Azure location to build the resources in."
  type        = string
}

variable "vnet_address_space" {
  description = "VNet address space in CIDR notation."
  type        = string
}

variable "create_nat_gateway" {
  description = "Whether to create a nat gateway for attachment in subnets. This is recommended, but it works also without. See https://docs.microsoft.com/en-us/azure/virtual-network/nat-gateway/nat-gateway-resource"
  type        = bool
  default     = false
}
