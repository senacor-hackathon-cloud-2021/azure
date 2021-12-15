output "vnet_name" {
  description = "The name of the Vnet."
  value       = azurerm_virtual_network.baseline.name
}

output "vnet_resource_group_name" {
  description = "The resource group name of the Vnet."
  value       = azurerm_virtual_network.baseline.resource_group_name
}

output "vnet_id" {
  description = "The Id of the Vnet."
  value       = azurerm_virtual_network.baseline.id
}

output "nat_gateway_id" {
  description = "The Id of the Nat Gateway, when created."
  value       = one(azurerm_nat_gateway.baseline_nat_gateway[*].id)
}
