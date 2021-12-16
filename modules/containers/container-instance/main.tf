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
    COMMON_PREFIX       = var.name_prefix
    APP_DEPLOYMENT_TYPE = "container-instance"
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

  docker_image_sha_ref = "${replace(var.docker_image, "/:.*$/", "")}@${data.docker_registry_image.this.sha256_digest}"
}


resource "azurerm_resource_group" "this" {
  name     = local.full_name
  location = var.azurerm_location

  tags = local.common_tags
}

resource "azurerm_container_group" "this" {
  name                = local.full_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_address_type = var.ip_address_type
  dns_name_label  = local.full_name
  os_type         = "Linux"

  container {
    name   = "main"
    image  = local.docker_image_sha_ref
    cpu    = var.cpu_cores
    memory = var.mem_gb

    environment_variables        = local.docker_env_vars
    secure_environment_variables = local.docker_secret_env_vars

    ports {
      port     = var.docker_http_port
      protocol = "TCP"
    }

    readiness_probe {
      initial_delay_seconds = 20
      failure_threshold     = 5
      period_seconds        = 10
      success_threshold     = 1
      timeout_seconds       = 1
      http_get {
        path   = var.docker_health_check_path
        port   = var.docker_http_port
        scheme = "Http"
      }
    }

    liveness_probe {
      initial_delay_seconds = 20
      failure_threshold     = 5
      period_seconds        = 10
      success_threshold     = 1
      timeout_seconds       = 1
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
    ignore_changes = [
      identity # avoid recreation because of ordering problems in identity list
    ]
  }

  tags = local.common_tags
}

data "docker_registry_image" "this" {
  name = var.docker_image
}
