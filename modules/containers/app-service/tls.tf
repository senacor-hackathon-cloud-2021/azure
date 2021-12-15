resource "azurerm_app_service_managed_certificate" "this" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.this.id
}

resource "azurerm_app_service_certificate_binding" "this" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.this.id
  certificate_id      = azurerm_app_service_managed_certificate.this.id
  ssl_state           = "SniEnabled"
}
