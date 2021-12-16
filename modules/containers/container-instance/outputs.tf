output "service_url" {
  value = "http://${replace(azurerm_dns_cname_record.this.fqdn, "/\\.$/", "")}:${var.docker_http_port}/"
}
