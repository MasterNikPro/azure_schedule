resource "azurerm_container_registry" "acr" {
  for_each = var.registry_instances

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = each.value.location
  sku                 = each.value.sku
  admin_enabled       = each.value.admin_enabled
}
