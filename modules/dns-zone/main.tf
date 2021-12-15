terraform {
  required_providers {
    azurerm = {
      version = "~>2.76"
    }
  }
}

locals {
  full_name = "${var.name_prefix}-dns"
}

resource "azurerm_resource_group" "this" {
  name     = local.full_name
  location = var.azurerm_location

  tags = local.common_tags
}

resource "azurerm_dns_zone" "this" {
  name                = var.zone_name
  resource_group_name = azurerm_resource_group.this.name

  tags = local.common_tags
}

resource "azurerm_private_dns_zone" "this" {
  for_each = toset(var.private_zone_names)

  name                = each.key
  resource_group_name = azurerm_resource_group.this.name

  tags = local.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = {
    for zone_net in setproduct(var.private_zone_names, var.private_zone_vnet_ids) :
    "${replace(zone_net[1], "/.*\\//", "")}--${zone_net[0]}" => {
      zone = zone_net[0]
      net  = zone_net[1]
    }
  }

  name                  = each.key
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value.zone].name
  virtual_network_id    = each.value.net

  tags = local.common_tags
}
