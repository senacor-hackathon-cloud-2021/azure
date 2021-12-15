variable "azurerm_tenant_id" {
  description = "The Azure AD tenant id for all resources."
  type        = string
}

variable "azurerm_subscription_id" {
  description = "The Azure subscription id for all resources."
  type        = string
}

variable "azurerm_location" {
  description = "The Azure location for all resources."
  type        = string
}

variable "azurerm_failover_location" {
  description = "The Azure failover location for all resources that require it."
  type        = string
}

variable "name_prefix" {
  type = string
}

variable "dns_zone_name" {
  description = "Name of the DNS zone name."
  type        = string
}

variable "docker_image" {
  description = "Name of the Docker image to run, form: docker.registry.com/path/to/image:latest"
  type        = string
}

variable "docker_http_port" {
  description = "HTTP Port exposed by the container. Use 8080 for typical Spring Boot apps, or 3000 for typical Node Apps."
  type        = number
}

variable "docker_health_check_path" {
  description = "Path to the HTTP health check if any. Must be a path that results in a HTTP 200 response when the container is healthy."
  type        = string
  default     = null
}
