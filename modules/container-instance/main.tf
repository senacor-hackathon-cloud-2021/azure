terraform {
  required_providers {
    azurerm = {
      version = "~>2.80"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~>2.15"
    }
  }
}

locals {
  full_name = "${var.name_prefix}-${var.name}"
  docker_static_env_vars = {
    COMMON_PREFIX = var.name_prefix
  }

  docker_secret_env_vars = {
    for key, value in var.secret_docker_env_vars :
    key => value
    #    key => "@Microsoft.KeyVault(VaultName=${var.secret_docker_env_vars_vault_name};SecretName=${value})"
  }

  docker_env_vars = merge(
    var.docker_env_vars,
    local.docker_static_env_vars,
  )
}


resource "azurerm_resource_group" "this" {
  name     = local.full_name
  location = var.azurerm_location

  tags = local.common_tags
}

resource "random_string" "name_suffix" {
  special = false
  length  = 5

  keepers = {
    full_name       = local.full_name
    ip_address_type = var.ip_address_type
    dns_name_label  = var.dns_name

    image  = var.docker_image
    cpu    = var.cpu_cores
    memory = var.mem_gb

    environment_variables        = join(",", values(local.docker_env_vars))
    secure_environment_variables = join(",", values(local.docker_secret_env_vars))

    port         = var.docker_http_port
    path         = var.docker_health_check_path
    identity_ids = join(",", local.managed_identity_ids)

    docker_registry_image = data.docker_registry_image.this.sha256_digest
  }
}

resource "azurerm_container_group" "this" {
  name                = "${local.full_name}-${random_string.name_suffix.result}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_address_type = var.ip_address_type
  dns_name_label  = "${local.full_name}-${random_string.name_suffix.result}"
  os_type         = "Linux"

  container {
    name   = "main"
    image  = var.docker_image
    cpu    = var.cpu_cores
    memory = var.mem_gb

    environment_variables        = local.docker_env_vars
    secure_environment_variables = local.docker_secret_env_vars

    ports {
      port     = var.docker_http_port
      protocol = "TCP"
    }

    readiness_probe {
      http_get {
        path   = var.docker_health_check_path
        port   = var.docker_http_port
        scheme = "Http"
      }
    }

    liveness_probe {
      http_get {
        path   = var.docker_health_check_path
        port   = var.docker_http_port
        scheme = "Http"
      }
    }
  }

  exposed_port {
    port     = var.docker_http_port
    protocol = "TCP"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = local.managed_identity_ids
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      identity # avoid
    ]
  }

  tags = local.common_tags
}

data "docker_registry_image" "this" {
  name = var.docker_image
}
