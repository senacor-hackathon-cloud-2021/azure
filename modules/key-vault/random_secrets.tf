locals {
  random_secret_names = toset(var.random_secret_names)
}

resource "random_password" "random" {
  for_each = local.random_secret_names

  length = 24
}

resource "azurerm_key_vault_secret" "random" {
  for_each = local.random_secret_names

  key_vault_id = azurerm_key_vault.this.id
  name         = each.key
  value        = random_password.random[each.key].result
}
