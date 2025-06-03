output "registry_ids" {
  description = "IDs of the created container registries"
  value       = { for k, v in azurerm_container_registry.acr : k => v.id }
}

output "registry_names" {
  description = "Names of the created container registries"
  value       = { for k, v in azurerm_container_registry.acr : k => v.name }
}