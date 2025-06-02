# Database instances configuration
variable "database_instances" {
  description = "Map of database instances to create"
  type = map(object({
    name                          = string
    type                          = string
    version                       = string
    size                          = string
    subnets                       = list(string)
    port                          = number
    security_groups               = list(string)
    network                       = string
    location                      = string
    sku_name                      = string
    storage_mb                    = number
    backup_retention_days         = optional(number, 7)
    geo_redundant_backup_enabled  = optional(bool, false)
    auto_grow_enabled             = optional(bool, false)
    public_network_access_enabled = optional(bool, true)
    allow_public_access           = optional(bool, false)
    start_ip_address              = optional(string, "0.0.0.0")
    end_ip_address                = optional(string, "255.255.255.255")
  }))
  default = {}
}

# Global configuration
variable "resource_group_name" {
  description = "The name of the resource group in which to create the PostgreSQL Flexible Server"
  type        = string
}

variable "administrator_login" {
  description = "The administrator login name for the PostgreSQL server"
  type        = string
  default     = "postgres"
}

variable "administrator_password" {
  description = "The administrator password for the PostgreSQL server"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.administrator_password) >= 8
    error_message = "Administrator password must be at least 8 characters long."
  }
}

variable "project_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
