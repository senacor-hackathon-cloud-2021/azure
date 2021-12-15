module "vnet" {
  source = "./modules/network/vnet"

  azurerm_location = var.azurerm_location
  name_prefix      = var.name_prefix
  name             = "baseline"

  vnet_address_space = "10.100.0.0/16"

  tags_prefix = var.tags_prefix
  common_tags = local.common_tags
}

module "subnet_main" {
  source = "./modules/network/subnet"

  name_prefix              = var.name_prefix
  name                     = "main"
  vnet_name                = module.vnet.vnet_name
  vnet_resource_group_name = module.vnet.vnet_resource_group_name

  subnet_address_prefixes = ["10.100.0.0/24"]

  tags_prefix = var.tags_prefix
  common_tags = local.common_tags
}

module "dns" {
  source = "./modules/dns-zone"

  azurerm_location = var.azurerm_location
  name_prefix      = var.name_prefix
  zone_name        = "azure.dobel.click"

  tags_prefix = var.tags_prefix
  common_tags = local.common_tags
}

module "vault" {
  source = "./modules/key-vault"

  azurerm_tenant_id = var.azurerm_tenant_id
  azurerm_location  = var.azurerm_location

  name_prefix = var.name_prefix
  name        = "vault"

  random_secret_names = ["demo1"]

  tags_prefix = var.tags_prefix
  common_tags = local.common_tags
}

module "app_service_public" {
  source = "./modules/app-service"

  azurerm_location = var.azurerm_location

  name_prefix = var.name_prefix
  name        = "public-appservice"

  app_service_plan_tier      = "Standard"
  app_service_plan_size      = "S1"
  app_service_plan_max_scale = 5

  dns_name                     = "public-appservice"
  dns_zone_name                = module.dns.zone_name
  dns_zone_resource_group_name = module.dns.zone_resource_group_name

  docker_image             = "ghcr.io/easimon/simple-rest-service:latest"
  docker_http_port         = 8080
  docker_health_check_path = "/health"

  docker_env_vars = {
    APP_ENVIRONMENT_ENDPOINT_ENABLED : true
    APP_ENVIRONMENT_ENDPOINT_FILTERED_PREFIXES : "APPSETTING_,WEBSITE_,IDENTITY_,MSI_"
  }

  vault_reader_identity_id          = module.vault.reader_identity_id
  secret_docker_env_vars_vault_name = module.vault.key_vault_name
  secret_docker_env_vars = {
    DEMO_SECRET = "demo1"
  }

  tags_prefix = var.tags_prefix
  common_tags = local.common_tags
}
