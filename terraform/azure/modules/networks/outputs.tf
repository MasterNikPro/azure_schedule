output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  value = azurerm_subnet.subnets[*].id
}

output "nsg_ids" {
  description = "Map of NSG names to their IDs"
  value = {
    for nsg_name, nsg in azurerm_network_security_group.nsg : nsg_name => nsg.id
  }
}
