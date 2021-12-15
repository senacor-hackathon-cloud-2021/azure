terraform {
  required_providers {
    azurerm = {
      version = "~>2.80"
    }
  }
}

locals {
  full_name = "${var.name_prefix}-${var.name}"
  docker_static_env_vars = {
    WEBSITES_PORT = var.docker_http_port
    COMMON_PREFIX = var.name_prefix
  }

  docker_secret_env_vars = {
    for key, value in var.secret_docker_env_vars :
    key => "@Microsoft.KeyVault(VaultName=${var.secret_docker_env_vars_vault_name};SecretName=${value})"
  }

  docker_env_vars = merge(
    var.docker_env_vars,
    local.docker_static_env_vars,
    local.docker_secret_env_vars,
  )
}


resource "azurerm_resource_group" "this" {
  name     = local.full_name
  location = var.azurerm_location

  tags = local.common_tags
}

resource "azurerm_app_service_plan" "this" {
  name                = "${local.full_name}-plan"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  kind                = "Linux"
  reserved            = true
  per_site_scaling    = true

  sku {
    tier = var.app_service_plan_tier
    size = var.app_service_plan_size
  }

  tags = local.common_tags
}

resource "azurerm_app_service" "this" {
  name                = "${local.full_name}-app"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  app_service_plan_id = azurerm_app_service_plan.this.id

  key_vault_reference_identity_id = var.vault_reader_identity_id
  identity {
    type         = "UserAssigned"
    identity_ids = local.managed_identity_ids
  }

  site_config {
    linux_fx_version                     = "DOCKER|${var.docker_image}"
    acr_use_managed_identity_credentials = local.managed_identity_client_id != null
    acr_user_managed_identity_client_id  = local.managed_identity_client_id

    health_check_path = var.docker_health_check_path

    vnet_route_all_enabled = true
    #    always_on              = true
    http2_enabled   = true
    min_tls_version = 1.2

    scm_type = "None"

    ip_restriction = []
  }

  app_settings = local.docker_env_vars

  tags = local.common_tags
}
