terraform {
  required_providers {
    azurerm = {
      version = "2.89.0"
    }
    azuread = {
      version = "2.12.0"
    }
    random = {
      version = "3.1.0"
    }
  }

  /*
  backend "azurerm" {
    environment          = "public"
    resource_group_name  = "terraform"
    storage_account_name = "tfsenacor"
    container_name       = "terraform-state"
    key                  = "senacor-cloud-containers/terraform.tfstate"
    use_azuread_auth     = true

    # Sourced from environment
    # tenant_id       = ARM_TENANT_ID
    # subscription_id = ARM_SUBSCRIPTION_ID
    # client_id       = ARM_CLIENT_ID
    # client_secret   = ARM_CLIENT_SECRET
  }
  */
}

provider "azuread" {
  tenant_id   = var.azurerm_tenant_id
  environment = "global"

  # Sourced from environment
  # client_id     = ARM_CLIENT_ID
  # client_secret = ARM_CLIENT_SECRET
}

provider "azurerm" {
  tenant_id       = var.azurerm_tenant_id
  subscription_id = var.azurerm_subscription_id
  environment     = "public"

  # Sourced from environment
  # client_id     = ARM_CLIENT_ID
  # client_secret = ARM_CLIENT_SECRET

  features {
    virtual_machine {
      graceful_shutdown = true
    }
  }
}
