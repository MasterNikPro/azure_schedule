resource "azurerm_log_analytics_workspace" "main" {
  name                = "example-law"
  resource_group_name = var.resource_group_name_azurerm
  location            = var.location_azurerm
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_storage_account" "main" {
  name                     = var.diagnostic_storage_account_name
  resource_group_name      = var.resource_group_name_azurerm
  location                 = var.location_azurerm
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_diagnostic_setting" "example" {
  for_each = var.vm_ids

  name                       = "${each.key}-diagnostic-setting"
  target_resource_id         = each.value
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Create Alert Rules (High CPU Usage)
resource "azurerm_monitor_metric_alert" "high_cpu_alert" {
  for_each            = var.vm_ids

  name                = "${each.key}-high-cpu-alert"
  resource_group_name = var.resource_group_name_azurerm
  scopes              = [each.value]
  description         = "Alert when CPU usage is high"
  severity            = 2
  window_size          = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Create Alert Rules (Memory Alert)
resource "azurerm_monitor_metric_alert" "memory_alert" {
  for_each            = var.vm_ids

  name                = "${each.key}-memory_alert"
  resource_group_name = var.resource_group_name_azurerm
  scopes              = [each.value]
  description         = "Alert for average available memory bytes"
  severity            = 2
  window_size          = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 200000000 
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

resource "azurerm_monitor_action_group" "main" {
  name                = "email-action-group"
  resource_group_name = var.resource_group_name_azurerm
  short_name          = "actiongrp"

  email_receiver {
    name          = "DolVladzio"
    email_address = "dolynkavladzio@gmail.com"
    use_common_alert_schema = true
  }
}
