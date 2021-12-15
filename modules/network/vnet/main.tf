terraform {
  required_providers {
    azurerm = {
      version = "~>2.80"
    }
  }
}

locals {
  baseline_name = "${var.name_prefix}-${var.name}"
}

resource "azurerm_resource_group" "baseline" {
  name     = local.baseline_name
  location = var.azurerm_location

  tags = local.common_tags
}

resource "azurerm_virtual_network" "baseline" {
  name                = local.baseline_name
  resource_group_name = azurerm_resource_group.baseline.name
  location            = azurerm_resource_group.baseline.location

  address_space = [var.vnet_address_space]

  tags = local.common_tags
}
