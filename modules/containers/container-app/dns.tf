locals {
  dns_ttl = 60
}

resource "azurerm_dns_cname_record" "this" {
  name                = var.dns_name
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name

  ttl    = local.dns_ttl
  record = local.template_output.fqdn.value

  tags = local.common_tags
}
