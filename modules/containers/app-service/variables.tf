variable "azurerm_location" {
  description = "Azure location to build the resources in."
  type        = string
}

variable "name_prefix" {
  description = "Common prefix to add to all resource names."
  type        = string
}

variable "name" {
  description = "Name of the app service."
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

variable "docker_env_vars" {
  description = "Environment variables exposed to the container."
  type        = map(string)
  default     = {}
}

variable "secret_docker_env_vars" {
  description = "Secret environment variables sourced from a key vault, exposed to the container."
  type        = map(string)
  default     = {}
}

variable "secret_docker_env_vars_vault_name" {
  description = "Vault to source environment variables from. Must be set if `secret_docker_env_vars` is not empty."
  type        = string
  default     = null
}

variable "vault_reader_identity_id" {
  description = "Identity granted to read from the vault to source environment variables from. Must be set if `secret_docker_env_vars` is not empty."
  type        = string
  default     = null
}

variable "docker_health_check_path" {
  description = "Path to the HTTP health check if any. Must be a path that results in a HTTP 200 response when the container is healthy."
  type        = string
  default     = null
}

variable "app_service_plan_size" {
  description = "Size of the app service plan. Must be a `PremiumV2` plan size to allow for VNET integration."
  type        = string
  default     = "S1"
}

variable "app_service_plan_tier" {
  description = "Service tier of the app service plan. Must be `PremiumV2` to allow for VNET integration."
  type        = string
  default     = "Standard"
}

variable "app_service_plan_max_scale" {
  description = "Maximum Number of workers assigned to the app service plan."
  type        = number
  default     = 1
}

variable "dns_name" {
  description = "(zone-local) DNS name bound to the app service."
  type        = string
}

variable "dns_zone_name" {
  description = "Name of the DNS Zone."
  type        = string
}

variable "dns_zone_resource_group_name" {
  description = "Resource group name of the DNS Zone."
  type        = string
}
