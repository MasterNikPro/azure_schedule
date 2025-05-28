locals {
  config = jsondecode(file("${path.module}/../config.json"))

  vnet_name           = "vnet-${local.config.project.environment}"
  location            = local.config.project.location_azurerm
  resource_group_name = local.config.project.resource_group_name_azurerm

  address_space   = [local.config.network[0].vpc_cidr]
  subnet_names    = [for s in local.config.network[0].subnets : s.name]
  subnet_prefixes = [for s in local.config.network[0].subnets : s.cidr]

  nsg_list = [
    for sg in local.config.security_groups : {
      name        = sg.name
      description = sg.description
      rules = [
        for rule in sg.ingress : {
          name                       = "${sg.name}-ingress-${rule.port}"
          priority                   = 100 + index(sg.ingress, rule)
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = title(rule.protocol)
          source_port_range          = "*"
          destination_port_range     = tostring(rule.port)
          source_address_prefix      = lookup(local.address_map, rule.source, "*")
          destination_address_prefix = "*"
        }
      ]
    }
  ]

  address_map = {
    "public"           = "0.0.0.0/0"
    "internal"         = local.config.network[0].vpc_cidr
    "frontend-sg"      = "10.0.2.4"
    "backend-sg"       = "10.0.2.5"
    "redis-sg"         = "10.0.2.6"
    "db-sg"            = "10.0.3.4"
    "reverse-proxy-sg" = "10.0.1.4"
    "bastion-sg"       = "10.0.1.5"
  }
}
