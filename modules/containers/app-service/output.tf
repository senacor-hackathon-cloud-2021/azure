output "service_url" {
  value = "https://${replace(azurerm_dns_cname_record.this.fqdn, "/\\.$/", "")}/"
}
