module "vm" {
  source                      = "./modules/vm"
  ssh_keys                    = local.config.project.keys
  vm_instances                = local.config.vm_instances
  hostname                    = local.config.project.vm_hostname
  terraform_username          = local.config.project.terraform_username
  resource_group_name_azurerm = local.config.project.resource_group_name_azurerm
  location_azurerm            = local.config.project.location_azurerm
  azurerm_subnet              = module.network.subnet_ids[0]
  nsg_ids                     = module.network.nsg_ids
}

module "network" {
  source              = "./modules/networks"
  vnet_name           = local.vnet_name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = local.address_space
  subnet_names        = local.subnet_names
  subnet_prefixes     = local.subnet_prefixes
  nsgs                = local.nsg_list
}
