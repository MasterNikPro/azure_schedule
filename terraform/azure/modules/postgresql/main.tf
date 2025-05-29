# Filter only PostgreSQL databases
locals {
  postgresql_instances = {
    for k, v in var.database_instances : k => v
    if v.type == "postgres"
  }
}

resource "azurerm_postgresql_flexible_server" "this" {
  for_each = local.postgresql_instances

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = each.value.location
  version             = each.value.version

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  sku_name = each.value.sku_name

  storage_mb                   = each.value.storage_mb
  backup_retention_days        = each.value.backup_retention_days
  geo_redundant_backup_enabled = each.value.geo_redundant_backup_enabled
  auto_grow_enabled            = each.value.auto_grow_enabled

  public_network_access_enabled = each.value.public_network_access_enabled


  tags = merge(var.project_tags, {
    Database = each.key
    Network  = each.value.network
  })
}
