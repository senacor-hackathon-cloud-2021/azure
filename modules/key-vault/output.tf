output "key_vault_id" {
  description = "The deployment key vault's Id that needs to be referenced in order to read/write secrets."
  value       = azurerm_key_vault.this.id
}

output "key_vault_name" {
  description = "The deployment key vault's name that needs to be referenced in order to read/write secrets."
  value       = azurerm_key_vault.this.name
}

output "reader_identity_id" {
  description = "Object Id of the managed identity that can be assigned to reading applications."
  value       = azurerm_user_assigned_identity.reader.id
}

output "reader_principal_id" {
  description = "Principal Id of the managed identity that can be assigned to reading applications."
  value       = azurerm_user_assigned_identity.reader.principal_id
}

output "reader_client_id" {
  description = "Client Id of the managed identity that can be assigned to reading applications."
  value       = azurerm_user_assigned_identity.reader.client_id
}

output "random_secret_names" {
  description = "List of names for random passwords / secrets to create, for demo purposes."
  value       = keys(random_password.random)
}

output "random_secrets" {
  description = "Map of names=>values for random passwords / secrets to create, for demo purposes."
  value       = { for key, value in random_password.random: key => value.result }
  sensitive   = true
}
