module "postgresql" {
  source = "./modules/postgresql"

  database_instances     = local.postgresql_instances
  resource_group_name    = local.project.resource_group_name_azurerm
  
  administrator_password = var.use_key_vault_for_db_credentials ? data.azurerm_key_vault_secret.db_password.value : var.db_admin_password
  administrator_login    = var.use_key_vault_for_db_credentials ? data.azurerm_key_vault_secret.db_username.value : var.db_admin_username

  project_tags = {
    Environment = local.project.environment
    ManagedBy   = "terraform"
    Project     = local.project.name
  }
}

module "network" {
  source              = "./modules/networks"
  vnet_name           = local.vnet_name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = local.address_space
  subnet_names        = local.subnet_names
  subnet_prefixes     = local.subnet_prefixes
  nsgs                = local.nsg_list
}
