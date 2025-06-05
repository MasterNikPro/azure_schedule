variable "location_azurerm" {}

variable "resource_group_name_azurerm" {}

variable "diagnostic_storage_account_name" {}

variable "vm_ids" {
  type        = map(string)
  description = "Map of VM keys to their IDs, passed from the vm module."
}

variable "monitor_metric_alert" {
  type = list(object({
    name                 = string
    description          = string
    scopes               = optional(list(string))
    target_resource_type = string
    severity             = optional(number)
    criteria = list(object({
      metric_namespace = string
      metric_name      = string
      aggregation      = string
      operator         = string
      threshold        = number
    }))
  }))
}


variable "log_analytics_workspace" {
  type = list(object({
    name              = string
    sku               = string
    retention_in_days = number
  }))
}

variable "azurerm_monitor_action_group" {
  type = list(object({
    name       = string
    short_name = string
    email_receiver = list(object({
      name                    = string
      email_address           = string
      use_common_alert_schema = bool
    }))
  }))
}
