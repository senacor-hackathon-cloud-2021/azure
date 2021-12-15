locals {
  dns_ttl = 60
}

resource "azurerm_dns_cname_record" "this" {
  name                = var.dns_name
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name

  ttl    = local.dns_ttl
  record = azurerm_container_group.this.fqdn

  tags = local.common_tags
}
