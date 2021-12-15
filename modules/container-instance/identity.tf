resource "azurerm_user_assigned_identity" "this" {
  name = "${local.full_name}-app-identity"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  tags = local.common_tags
}

locals {
  managed_identity_ids       = toset(compact([azurerm_user_assigned_identity.this.id, var.vault_reader_identity_id]))
  managed_identity_client_id = azurerm_user_assigned_identity.this.client_id
}
