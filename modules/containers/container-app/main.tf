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
    APP_DEPLOYMENT_TYPE = "container-app"
  }

  docker_secret_env_vars = var.secret_docker_env_vars

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

locals {
  resource_group_name = azurerm_resource_group.this.name
  app_name            = "${local.resource_group_name}-ca"
  environment_name    = "${local.resource_group_name}-env"
  workspace_name      = "${local.resource_group_name}-logs"
  parameters = {
    name     = local.app_name
    location = var.azurerm_location
    containers = [{
      name    = "main"
      image   = local.docker_image_sha_ref
      command = []
      args    = []
      env = concat(
        [for k, v in local.docker_env_vars : { name = k, value = v }],
        [for k, v in local.docker_secret_env_vars : { name = k, secretRef = replace(lower(k), "_", "-") }]
      )
      resources = {
        cpu    = var.cpu_cores
        memory = "${var.cpu_cores * 2}Gi"
      }
    }]
    registries = []
    secrets    = [for k, v in local.docker_secret_env_vars : { name = replace(lower(k), "_", "-"), value = v }]
    ingress = {
      external   = true,
      targetPort = var.docker_http_port,
      transport  = "auto"
    }
    minReplicas = var.min_replicas
    maxReplicas = var.max_replicas
    scalingRules = [{
      name = "cpu-scaling-rule"
      custom = {
        type = "cpu",
        metadata = {
          type  = "Utilization",
          value = "75"
        }
      }
    }]
    environmentName   = local.environment_name
    workspaceName     = local.workspace_name
    workspaceLocation = var.azurerm_location
    commonTags        = local.common_tags
  }
  parameters_content = jsonencode({ for k, v in local.parameters : k => { value = v } })
  template_content   = file("${path.module}/arm-template/container-app-template.json")

  tags = local.common_tags
}

resource "azurerm_resource_group_template_deployment" "this" {
  name                = local.app_name
  resource_group_name = azurerm_resource_group.this.name

  deployment_mode    = "Complete"
  template_content   = local.template_content
  parameters_content = local.parameters_content
}

data "docker_registry_image" "this" {
  name = var.docker_image
}
