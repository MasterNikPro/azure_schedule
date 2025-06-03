variable "registry_instances" {
  description = "Map of container registry instances to create"
  type = map(object({
    name                          = string
    location                      = string
    sku                           = string
    admin_enabled                 = bool
    public_network_access_enabled = bool
    tags                          = optional(map(string))
  }))
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the container registry"
  type        = string
}

variable "project_tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
} 