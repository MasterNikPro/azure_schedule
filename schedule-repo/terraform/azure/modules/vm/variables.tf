variable "location_azurerm" {}

variable "resource_group_name_azurerm" {}

variable "ssh_keys" {}

variable "vm_instances" {
  type = list(object({
    name            = string
    network         = string
    size            = string
    zone            = string
    subnet          = string
    tags            = set(string)
    port            = number
    security_groups = optional(list(string), [])
    public_ip       = bool
  }))
  description = "List of VMs (from config.json)"
}

variable "hostname" {}

variable "terraform_username" {}

variable "azurerm_subnet" {}

variable "nsg_ids" {}
