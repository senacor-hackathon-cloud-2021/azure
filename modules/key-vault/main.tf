terraform {
  required_providers {
    azurerm = {
      version = "~>2.80"
    }
    random = {
      version = "~>3.1"
    }
  }
}

locals {
  full_name    = "${var.name_prefix}-${var.name}"
  full_name_kv = substr(replace(local.full_name, "/[^A-Za-z0-9-]/", ""), 0, 24) # vault name may contain only alphanumeric chars and dash
}

resource "azurerm_resource_group" "this" {
  name     = local.full_name
  location = var.azurerm_location

  tags = local.common_tags
}

resource "azurerm_key_vault" "this" {
  name = local.full_name_kv

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  enabled_for_disk_encryption = true

  tenant_id                  = var.azurerm_tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  sku_name                   = "standard"

  tags = local.common_tags
}

resource "azurerm_user_assigned_identity" "reader" {
  name = "${local.full_name}-reader"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  tags = local.common_tags
}

resource "azurerm_key_vault_access_policy" "reader" {
  for_each = toset(var.secret_reader_object_ids)

  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.azurerm_tenant_id
  object_id    = each.key

  secret_permissions = [
    "List",
    "Get",
  ]
}

resource "azurerm_key_vault_access_policy" "msi_reader" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.azurerm_tenant_id
  object_id    = azurerm_user_assigned_identity.reader.principal_id

  secret_permissions = [
    "List",
    "Get",
  ]
}

resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.azurerm_tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "List",
    "Get",
    "Set",
    "Delete",
    "Purge",
    "Recover",
    "Backup",
    "Restore",
  ]
}

data "azurerm_client_config" "current" {}
