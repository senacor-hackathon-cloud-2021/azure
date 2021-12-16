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
    WEBSITES_PORT       = var.docker_http_port
    COMMON_PREFIX       = var.name_prefix
    APP_DEPLOYMENT_TYPE = "app-service"
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

  docker_image_sha     = data.docker_registry_image.this.sha256_digest
  docker_image_sha_short = replace(local.docker_image_sha, "/.*:([a-f0-9]{5}).*/", "$1")
  docker_image_sha_ref = "${replace(var.docker_image, "/:.*$/", "")}@${local.docker_image_sha}"
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
  per_site_scaling    = false

  sku {
    tier = var.app_service_plan_tier
    size = var.app_service_plan_size
  }

  tags = local.common_tags
}

locals {

  setting_constants = {
    https_only = true
  }
}

resource "azurerm_app_service" "this" {
  name                = "${local.full_name}-appservice"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  app_service_plan_id = azurerm_app_service_plan.this.id

  https_only = local.setting_constants.https_only

  identity {
    type         = "UserAssigned"
    identity_ids = local.managed_identity_ids
  }
  key_vault_reference_identity_id = var.vault_reader_identity_id

  site_config {
    linux_fx_version = "DOCKER|${local.docker_image_sha_ref}"

    health_check_path = var.docker_health_check_path

    vnet_route_all_enabled = true
    http2_enabled          = true
    websockets_enabled     = true

    min_tls_version = 1.2
    scm_type        = "None"

    ip_restriction = []
  }

  storage_account {
    name         = azurerm_storage_account.this.name
    type         = "AzureBlob"
    account_name = azurerm_storage_account.this.name
    share_name   = azurerm_storage_container.this.name
    access_key   = azurerm_storage_account.this.primary_access_key
    mount_path   = "/static-files"
  }

  logs {
    application_logs {
      file_system_level = "Information"
    }
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 50
      }

    }
    detailed_error_messages_enabled = true
  }

  storage_account {
    name         = azurerm_storage_account.this.name
    type         = "AzureBlob"
    account_name = azurerm_storage_account.this.name
    share_name   = azurerm_storage_container.this.name
    access_key   = azurerm_storage_account.this.primary_access_key
    mount_path   = "/static-files"
  }

  tags = local.common_tags
}

locals {
}

/**
// This is quite incomplete
// - Storage account not settable, storage is then lost after switching slots
// - No way to wait for new slot to come up healthy before switching

resource "azurerm_app_service_slot" "this" {
  for_each = toset([local.docker_image_sha_ref])

  name                = local.docker_image_sha_short
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  app_service_plan_id = azurerm_app_service_plan.this.id
  app_service_name    = azurerm_app_service.this.name

  https_only = local.setting_constants.https_only

  identity {
    type         = "UserAssigned"
    identity_ids = local.managed_identity_ids
  }
  key_vault_reference_identity_id = var.vault_reader_identity_id

  site_config {
    linux_fx_version = "DOCKER|${local.docker_image_sha_ref}"

    health_check_path = var.docker_health_check_path

    vnet_route_all_enabled = true
    http2_enabled          = true
    websockets_enabled     = true

    min_tls_version = 1.2
    scm_type        = "None"

    ip_restriction = []
  }

  logs {
    application_logs {
      file_system_level = "Information"
    }
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 50
      }

    }
    detailed_error_messages_enabled = true
  }

  app_settings = local.docker_env_vars

  storage_account {
    name         = azurerm_storage_account.this.name
    type         = "AzureBlob"
    account_name = azurerm_storage_account.this.name
    share_name   = azurerm_storage_container.this.name
    access_key   = azurerm_storage_account.this.primary_access_key
    mount_path   = "/static-files"
  }

  tags = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_app_service_active_slot" "this" {
  resource_group_name   = azurerm_resource_group.this.name
  app_service_name      = azurerm_app_service.this.name
  app_service_slot_name = values(azurerm_app_service_slot.this)[0].name
}
*/

data "docker_registry_image" "this" {
  name = var.docker_image
}
