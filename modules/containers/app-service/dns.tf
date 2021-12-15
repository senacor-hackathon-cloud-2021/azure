locals {
  dns_ttl = 150
}

resource "azurerm_dns_cname_record" "this" {
  name                = var.dns_name
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name

  ttl    = local.dns_ttl
  record = azurerm_app_service.this.default_site_hostname

  tags = local.common_tags
}

resource "azurerm_app_service_custom_hostname_binding" "this" {
  hostname = trimsuffix(azurerm_dns_cname_record.this.fqdn, ".")

  app_service_name    = azurerm_app_service.this.name
  resource_group_name = azurerm_resource_group.this.name

  depends_on = [azurerm_dns_txt_record.custom_hostname_verification]

  lifecycle {
    ignore_changes = [ssl_state, thumbprint]
  }
}

resource "azurerm_dns_txt_record" "custom_hostname_verification" {
  name                = "asuid.${var.dns_name}"
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_zone_resource_group_name

  ttl = local.dns_ttl

  record {
    value = azurerm_app_service.this.custom_domain_verification_id
  }

  tags = local.common_tags
}
