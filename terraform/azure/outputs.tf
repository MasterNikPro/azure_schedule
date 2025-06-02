output "database_server_id" {
  description = "The ID of the first PostgreSQL Flexible Server"
  value       = module.postgresql.server_id
}

output "config_summary" {
  description = "Summary of configuration loaded from config.json"
  value = {
    project_name    = local.project.name
    environment     = local.project.environment
    location        = local.project.location_azurerm
    resource_group  = local.project.resource_group_name_azurerm
    total_databases = length(local.db_instances)
    key_vault_integration = {
      auth_enabled           = var.use_key_vault_for_auth
      db_credentials_enabled = var.use_key_vault_for_db_credentials
      key_vault_name         = local.project.key_vault_name_azurerm
    }
  }
}

output "vnet_id" {
  value = module.networks.vnet_id
}
