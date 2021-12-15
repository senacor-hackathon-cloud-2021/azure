variable "azurerm_location" {
  description = "Azure location to build the resources in."
  type        = string
}

variable "name_prefix" {
  description = "Common prefix to add to all resource names."
  type        = string
}

variable "zone_name" {
  description = "Name of the DNS zone (the domain name)."
  type        = string
}

variable "private_zone_names" {
  description = "Name of private DNS zones (the domain names) to create."
  type        = list(string)
  default     = []
}

variable "private_zone_vnet_ids" {
  description = "VNet IDs of VNets that will be attached to the private zone."
  type        = list(string)
  default     = []
}
