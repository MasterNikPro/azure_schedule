# Read and parse the config.json file
locals {
  config = jsondecode(file("../config.json"))
  
  # Extract database instances from config
  db_instances = local.config.databases
  
  # Extract project configuration
  project = local.config.project
  
  # Map database configurations for Azure PostgreSQL
  postgresql_instances = {
    for db in local.db_instances : db.name => {
      name                          = "${local.project.name}-${db.name}-${local.project.environment}"
      type                          = db.type
      version                       = tostring(db.version)
      size                          = db.size
      subnets                       = db.subnets
      port                          = db.port
      security_groups               = db.security_groups
      network                       = db.network
      location                      = local.project.location_azurerm
      
      # Map size to Azure SKU
      sku_name = db.sku_name
      # Map size to storage
      storage_mb = (db.size == "small" ? 32768 : 
                   db.size == "medium" ? 65536 : 
                   db.size == "large" ? 131072 : 65536)
                   
      # Optional settings with defaults
      backup_retention_days         = lookup(db, "backup_retention_days", 7)
      geo_redundant_backup_enabled  = lookup(db, "geo_redundant_backup_enabled", false)
      auto_grow_enabled             = lookup(db, "auto_grow_enabled", false)
      public_network_access_enabled = lookup(db, "public_network_access_enabled", true)
    }
    if db.type == "postgres"
  }
} 