resource "azurerm_public_ip" "baseline_nat_gateway" {
  count = var.create_nat_gateway ? 1 : 0

  name                = "${local.baseline_name}-private-app-natgw"
  resource_group_name = azurerm_resource_group.baseline.name
  location            = azurerm_resource_group.baseline.location

  allocation_method = "Static"
  sku               = "Standard"

  tags = local.common_tags
}

resource "azurerm_nat_gateway" "baseline_nat_gateway" {
  count = var.create_nat_gateway ? 1 : 0

  name                = "${local.baseline_name}-private-app-natgw"
  resource_group_name = azurerm_resource_group.baseline.name
  location            = azurerm_resource_group.baseline.location

  sku_name                = "Standard"
  idle_timeout_in_minutes = 10

  tags = local.common_tags
}

resource "azurerm_nat_gateway_public_ip_association" "baseline_nat_gateway" {
  count = var.create_nat_gateway ? 1 : 0

  nat_gateway_id       = azurerm_nat_gateway.baseline_nat_gateway[count.index].id
  public_ip_address_id = azurerm_public_ip.baseline_nat_gateway[count.index].id
}
