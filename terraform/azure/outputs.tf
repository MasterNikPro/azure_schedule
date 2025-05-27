# Legacy outputs for backward compatibility (first database instance)
output "database_server_name" {
  description = "The name of the first PostgreSQL Flexible Server"
  value       = module.postgresql.server_name
}

output "database_fqdn" {
  description = "The FQDN of the first PostgreSQL Flexible Server"
  value       = module.postgresql.server_fqdn
}

output "database_location" {
  description = "The location of the PostgreSQL Flexible Server"
  value       = module.postgresql.server_location
}

output "database_admin_login" {
  description = "The administrator login name for the PostgreSQL server"
  value       = var.db_admin_username
}

output "database_server_id" {
  description = "The ID of the first PostgreSQL Flexible Server"
  value       = module.postgresql.server_id
}

output "database_version" {
  description = "The version of the first PostgreSQL instance"
  value       = module.postgresql.postgresql_version
}

output "config_summary" {
  description = "Summary of configuration loaded from config.json"
  value = {
    project_name = local.project.name
    environment = local.project.environment
    location = local.project.location_azurerm
    resource_group = local.project.resource_group_name_azurerm
    total_databases = length(local.db_instances)
    key_vault_integration = {
      auth_enabled = var.use_key_vault_for_auth
      db_credentials_enabled = var.use_key_vault_for_db_credentials
      key_vault_name = local.project.key_vault_name_azurerm
    }
  }
}