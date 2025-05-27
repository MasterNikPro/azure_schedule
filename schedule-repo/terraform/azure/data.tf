data "azurerm_client_config" "current" {}

# Get Key Vault reference
data "azurerm_key_vault" "main" {
  name                = local.project.key_vault_name_azurerm
  resource_group_name = local.project.resource_group_name_azurerm
}

data "azurerm_key_vault_secret" "db_username" {
  name         = "db-username"
  key_vault_id = data.azurerm_key_vault.main.id
}

data "azurerm_key_vault_secret" "db_password" {
  name         = "db-pass"
  key_vault_id = data.azurerm_key_vault.main.id
}
