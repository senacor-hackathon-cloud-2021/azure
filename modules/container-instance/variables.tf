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

variable "ip_address_type" {
  description = "Specifies the ip address type of the container. `Public` or `Private`. Changing this forces a new resource to be created. If set to `Private`, network_profile_id also needs to be set."
  type        = string
  default     = "Public"
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

variable "cpu_cores" {
  description = "Amount of VCPU cores assigned to the container."
  type        = number
  default     = 1
}

variable "mem_gb" {
  description = "Amount of Memory in GB cores assigned to the container."
  type        = number
  default     = 0.5
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
