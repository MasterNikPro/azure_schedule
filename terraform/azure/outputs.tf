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

# Database outputs
output "postgresql_instances" {
  description = "Information about created PostgreSQL instances"
  value       = module.postgresql.postgresql_instances
}

output "database_connection_strings" {
  description = "Database connection information"
  value       = module.postgresql.database_connection_strings
  sensitive   = false
}

output "config_summary" {
  description = "Summary of configuration loaded from config.json"
  value = {
    project_name = local.project.name
    environment = local.project.environment
    location = local.project.location_azurerm
    resource_group = local.project.resource_group_name_azurerm
    total_databases = length(local.db_instances)
    postgresql_databases = length(local.postgresql_instances)
  }
}
