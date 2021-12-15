output "zone_id" {
  description = "ID of the DNS zone created."
  value       = azurerm_dns_zone.this.id
}

output "private_zone_ids" {
  description = "ID of the private DNS zones created."
  value       = { for zone in azurerm_private_dns_zone.this : zone.name => zone.id }
}

output "zone_name" {
  description = "Name of the DNS zone created."
  value       = azurerm_dns_zone.this.name
}

output "zone_resource_group_name" {
  description = "Resource group name of the DNS zone created."
  value       = azurerm_dns_zone.this.resource_group_name
}

output "zone_nameservers" {
  description = "Name servers of the DNS zone created."
  value       = azurerm_dns_zone.this.name_servers
}
