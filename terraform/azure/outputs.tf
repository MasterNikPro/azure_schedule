### POSTGRESQL #####################################
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
### NETWORKS #######################################
output "vnet_id" {
  value = module.networks.vnet_id
}

output "subnet_ids" {
  value = module.networks.subnet_ids
}

output "nsg_ids" {
  value = module.networks.nsg_ids
}
### VM #############################################
output "vm_name" {
  value = module.vm.vm_name
}
### Container_Registry #############################
output "container_registry_ids" {
  description = "IDs of the created container registries"
  value       = module.container_registry.registry_ids
}

output "container_registry_names" {
  description = "Names of the created container registries"
  value       = module.container_registry.registry_names
}
### LoadBalancer ###################################
output "load_balancer_name" {
  value = module.load_balancer.debug_lb
}
