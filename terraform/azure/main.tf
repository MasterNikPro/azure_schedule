module "vm" {
  source                      = "./modules/vm"
  ssh_keys                    = local.config.project.keys
  vm_instances                = local.config.vm_instances
  hostname                    = local.config.project.vm_hostname
  terraform_username          = local.config.project.terraform_username
  resource_group_name_azurerm = local.config.project.resource_group_name_azurerm
  location_azurerm            = local.config.project.location_azurerm
  azurerm_subnet              = module.networks.subnet_ids[0]
  nsg_ids                     = module.networks.nsg_ids
  vm_instances_size_map       = local.config.vm_instances_size_map
  os_disk                     = local.config.os_disk
  os_image                    = local.config.os_image

  depends_on = [module.networks]
}

module "networks" {
  source              = "./modules/networks"
  vnet_name           = local.vnet_name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = local.address_space
  subnet_names        = local.subnet_names
  subnet_prefixes     = local.subnet_prefixes
  nsgs                = local.nsg_list
}

module "postgresql" {
  source = "./modules/postgresql"

  database_instances     = local.postgresql_instances
  resource_group_name    = local.project.resource_group_name_azurerm
  administrator_password = data.azurerm_key_vault_secret.db_password.value
  administrator_login    = data.azurerm_key_vault_secret.db_username.value
  project_tags = {
    Environment = local.project.environment
    ManagedBy   = "terraform"
    Project     = local.project.name
  }

  depends_on = [module.networks]
}

module "container_registry" {
  source = "./modules/container_registry"

  registry_instances  = local.container_registry_instances
  resource_group_name = local.project.resource_group_name_azurerm

  project_tags = {
    Environment = local.project.environment
    ManagedBy   = "terraform"
    Project     = local.project.name
  }
}

module "load_balancer" {
    source = "./modules/loadbalancer"
    load_balancer  = local.load_balancer
  project_values = local.project_values
  
}