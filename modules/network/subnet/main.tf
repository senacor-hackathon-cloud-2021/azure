terraform {
  required_providers {
    azurerm = {
      version = "~>2.80"
    }
  }
}

locals {
  subnet_name = "${var.name_prefix}-${var.name}"
}

resource "azurerm_subnet" "subnet" {
  name = local.subnet_name

  virtual_network_name                           = var.vnet_name
  resource_group_name                            = var.vnet_resource_group_name
  enforce_private_link_endpoint_network_policies = var.enforce_private_link_endpoint_network_policies
  address_prefixes                               = var.subnet_address_prefixes
  service_endpoints                              = var.service_endpoints
}

resource "azurerm_subnet_nat_gateway_association" "nat" {
  count = var.nat_gateway_id != null ? 1 : 0

  subnet_id      = azurerm_subnet.subnet.id
  nat_gateway_id = var.nat_gateway_id
}
