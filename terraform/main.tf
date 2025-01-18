terraform {
  backend "azurerm" {
  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.service_shortcut}-${var.environment_tag}"
  location = "West Europe"
}

resource "azurerm_key_vault" "kv" {
  name                        = "kv-${var.service_shortcut}-${var.environment_tag}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true

  sku_name = "standard"
}

resource "azurerm_storage_account" "sa" {
  name                     = "sa${var.service_shortcut}${var.environment_tag}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Service Plan
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan
resource "azurerm_service_plan" "sp" {
  name                = "splan-${var.service_shortcut}-${var.environment_tag}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_application_insights" "appinsights" {
  name                = "appinsights-${var.service_shortcut}-${var.environment_tag}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "other"
}

resource "azurerm_linux_function_app" "functions" {
  name                       = "funcapp-${var.service_shortcut}-${var.environment_tag}"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  service_plan_id            = azurerm_service_plan.sp.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  https_only                 = true



  app_settings = {
    # FUNCTIONS_WORKER_RUNTIME = "custom"
    # SPAUTH_SITEURL           = var.sharepoint_siteurl
    # SPAUTH_CLIENTID          = var.sharepoint_clientid
    # SPAUTH_CLIENTSECRET      = var.sharepoint_clientsecret

    FUNCTION_APP_EDIT_MODE = "readonly"
    # HASH                     = base64encode(filesha256(var.package))
    # WEBSITE_RUN_FROM_PACKAGE = "https://${azurerm_storage_account.storage.name}.blob.core.windows.net/${azurerm_storage_container.deployments.name}/${azurerm_storage_blob.appcode.name}${data.azurerm_storage_account_sas.sas.sas}"

    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appinsights.instrumentation_key
  }

  site_config {}

}

import {
  to = azurerm_resource_group.rg
  id = "/subscriptions/7a8c32c6-f593-43cd-ab54-99105fd2cc8b/resourceGroups/rg-fintrack-dev"
}

import {
  to = azurerm_key_vault.kv
  id = "/subscriptions/7a8c32c6-f593-43cd-ab54-99105fd2cc8b/resourceGroups/rg-fintrack-dev/providers/Microsoft.KeyVault/vaults/kv-fintrack-dev"
}

import {
  to = azurerm_storage_account.sa
  id = "/subscriptions/7a8c32c6-f593-43cd-ab54-99105fd2cc8b/resourceGroups/rg-fintrack-dev/providers/Microsoft.Storage/storageAccounts/safintrackdev"
}

