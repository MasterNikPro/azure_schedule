resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnets" {
  count                = length(var.subnet_names)
  name                 = var.subnet_names[count.index]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefixes[count.index]]
}

resource "azurerm_network_security_group" "nsg" {
  for_each            = { for nsg in var.nsgs : nsg.name => nsg }
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
}

locals {
  all_nsg_rules = {
    for pair in flatten([
      for nsg in var.nsgs : [
        for rule in nsg.rules : {
          key   = "${nsg.name}-${rule.name}"
          value = merge(rule, { nsg_name = nsg.name })
        }
      ]
    ]) : pair.key => pair.value
  }
}

resource "azurerm_network_security_rule" "nsg_rules" {
  for_each = local.all_nsg_rules

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = each.value.nsg_name

  depends_on = [
    azurerm_network_security_group.nsg
  ]
}
