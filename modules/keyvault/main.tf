
# data
data "azurerm_client_config" "current" {}
locals {
  key_vault_permissions         = ["List", "Get", "Update", "Create", "Delete", "Recover"]
  key_vault_secret_permissions  = ["Get", "List", "Set", "Delete", "Recover", "Purge"]
  key_vault_storage_permissions = ["Backup", "Delete", "Get", "List", "Recover"]
}
# key vault
resource "azurerm_key_vault" "key_vault" {
  name                        = "${var.project}-${var.environment}-key-vault"
  location                    = var.location
  resource_group_name         = var.rg_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = local.key_vault_permissions

    secret_permissions = local.key_vault_secret_permissions

    storage_permissions = local.key_vault_storage_permissions
  }
}

# secret
resource "azurerm_key_vault_secret" "github_token" {
  name         = "githubtoken"
  value        = var.github_token
  key_vault_id = azurerm_key_vault.key_vault.id
}
