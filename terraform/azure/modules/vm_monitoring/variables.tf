variable "location_azurerm" {}

variable "resource_group_name_azurerm" {}

variable "diagnostic_storage_account_name" {}

variable "vm_ids" {}

# variable "azurerm_monitor_metric_alert" {
# 	type = list(object({
# 		name = string
# 		description = string
# 		severity = number
# 		window_size = string
# 		criteria = list(object({
# 			metric_namespace = string
# 			metric_name = string
# 			aggregation = string
# 			operator = string
# 			threshold = number
# 		}))
# 	}))
# }

variable "azurerm_monitor_action_group" {
	type = list(object({
		name = string
		short_name = string
		email_receiver = list(object({
			name = string
			email_address = string
			use_common_alert_schema = bool
		}))
	}))
}
