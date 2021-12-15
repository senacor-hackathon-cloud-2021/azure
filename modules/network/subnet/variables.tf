variable "name_prefix" {
  description = "Common prefix to add to all resource names."
  type        = string
}

variable "name" {
  description = "Name of the subnet, prefixed by name_prefix."
  type        = string
}

variable "vnet_name" {
  description = "Name of the Vnet to attach this subnet in."
  type        = string
}

variable "vnet_resource_group_name" {
  description = "Name of the Vnet's resource group name to attach this subnet in."
  type        = string
}

variable "subnet_address_prefixes" {
  description = "Subnet address space(s) in CIDR notation. Must be a parts of the VNet's address space."
  type        = list(string)
}

variable "enforce_private_link_endpoint_network_policies" {
  description = "If private link endpoints are allowed on the subnet"
  type        = bool
  default     = false
}

variable "service_endpoints" {
  description = <<-EOF
    (Optional) The list of Service endpoints to associate with the subnet. Possible values include:
    `Microsoft.AzureActiveDirectory`, `Microsoft.AzureCosmosDB`, `Microsoft.ContainerRegistry`,
    `Microsoft.EventHub`, `Microsoft.KeyVault`, `Microsoft.ServiceBus`, `Microsoft.Sql`, `Microsoft.Storage` and `Microsoft.Web`.
  EOF
  type        = list(string)
  default     = []
}

variable "nat_gateway_id" {
  description = "Nat Gateway Id to attach to the subnet, if any."
  type        = string
  default     = null
}
