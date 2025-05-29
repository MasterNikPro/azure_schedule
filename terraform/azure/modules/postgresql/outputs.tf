# Multiple instances outputs
output "postgresql_instances" {
  description = "Map of all PostgreSQL instances"
  value = {
    for k, v in azurerm_postgresql_flexible_server.this : k => {
      server_id                     = v.id
      server_name                   = v.name
      server_fqdn                   = v.fqdn
      server_location               = v.location
      administrator_login           = v.administrator_login
      postgresql_version            = v.version
      sku_name                      = v.sku_name
      storage_mb                    = v.storage_mb
      backup_retention_days         = v.backup_retention_days
      public_network_access_enabled = v.public_network_access_enabled
      zone                          = v.zone
    }
  }
}

output "database_connection_strings" {
  description = "Database connection information for all instances"
  value = {
    for k, v in azurerm_postgresql_flexible_server.this : k => {
      host              = v.fqdn
      port              = local.postgresql_instances[k].port
      database          = k
      username          = v.administrator_login
      connection_string = "postgresql://${v.administrator_login}:PASSWORD@${v.fqdn}:${local.postgresql_instances[k].port}/${k}"
    }
  }
  sensitive = false
}

# Legacy outputs for backward compatibility (first instance)
output "server_id" {
  description = "The ID of the first PostgreSQL Flexible Server"
  value       = length(azurerm_postgresql_flexible_server.this) > 0 ? values(azurerm_postgresql_flexible_server.this)[0].id : null
}

output "server_name" {
  description = "The name of the first PostgreSQL Flexible Server"
  value       = length(azurerm_postgresql_flexible_server.this) > 0 ? values(azurerm_postgresql_flexible_server.this)[0].name : null
}

output "server_fqdn" {
  description = "The FQDN of the first PostgreSQL Flexible Server"
  value       = length(azurerm_postgresql_flexible_server.this) > 0 ? values(azurerm_postgresql_flexible_server.this)[0].fqdn : null
}

output "server_location" {
  description = "The location of the first PostgreSQL Flexible Server"
  value       = length(azurerm_postgresql_flexible_server.this) > 0 ? values(azurerm_postgresql_flexible_server.this)[0].location : null
}

output "administrator_login" {
  description = "The administrator login name for the PostgreSQL server"
  value       = length(azurerm_postgresql_flexible_server.this) > 0 ? values(azurerm_postgresql_flexible_server.this)[0].administrator_login : null
}

output "postgresql_version" {
  description = "The version of the first PostgreSQL instance"
  value       = length(azurerm_postgresql_flexible_server.this) > 0 ? values(azurerm_postgresql_flexible_server.this)[0].version : null
}

output "sku_name" {
  description = "The SKU name of the first PostgreSQL Flexible Server"
  value       = length(azurerm_postgresql_flexible_server.this) > 0 ? values(azurerm_postgresql_flexible_server.this)[0].sku_name : null
}

output "storage_mb" {
  description = "The storage size in MB of the first PostgreSQL Flexible Server"
  value       = length(azurerm_postgresql_flexible_server.this) > 0 ? values(azurerm_postgresql_flexible_server.this)[0].storage_mb : null
}

output "backup_retention_days" {
  description = "The backup retention days of the first PostgreSQL Flexible Server"
  value       = length(azurerm_postgresql_flexible_server.this) > 0 ? values(azurerm_postgresql_flexible_server.this)[0].backup_retention_days : null
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled for the first instance"
  value       = length(azurerm_postgresql_flexible_server.this) > 0 ? values(azurerm_postgresql_flexible_server.this)[0].public_network_access_enabled : null
}
