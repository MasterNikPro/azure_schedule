provider "azurerm" {
  features {}

  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

}

module "postgresql" {
  source = "./modules/postgresql"

  database_instances     = local.postgresql_instances
  resource_group_name    = local.project.resource_group_name_azurerm
  administrator_password = var.db_admin_password
  administrator_login    = var.db_admin_username

  project_tags = {
    Environment = local.project.environment
    ManagedBy   = "terraform"
    Project     = local.project.name
  }
}
