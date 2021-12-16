locals {
  template_output = jsondecode(azurerm_resource_group_template_deployment.this.output_content)
}

output "service_url" {
  value = try(local.template_output.serviceUrl.value, null)
}
