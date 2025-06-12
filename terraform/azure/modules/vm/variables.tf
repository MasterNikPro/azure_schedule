variable "location_azurerm" {}

variable "resource_group_name_azurerm" {}

variable "ssh_keys" {}

variable "vm_instances" {
  description = "List of VM instances with their configurations"
  type = list(object({
    name                          = string
    zone                          = string
    tags                          = list(string)
    public_ip                     = bool
    security_groups               = list(string)
    allocation_method             = string
    ip_configuration_name         = string
    private_ip_address_allocation = string
    size                          = string
  }))
}

variable "hostname" {}

variable "terraform_username" {}

variable "azurerm_subnet" {}

variable "nsg_ids" {}

variable "vm_instances_size_map" {
  description = "Mapping of VM sizes for each region"
  type = map(object({
    small  = string
    medium = string
    large  = string
  }))
}

variable "os_disk" {
  description = "List of VM image sizes"
  type = map(object({
    caching              = string
    storage_account_type = string
  }))
}

variable "os_image" {
  description = "List of VM image sizes"
  type = map(object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  }))
}

# variable "storage_account_uri" {}
