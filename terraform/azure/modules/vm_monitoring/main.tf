resource "azurerm_storage_account" "main" {
  name                     = var.diagnostic_storage_account_name
  resource_group_name      = var.resource_group_name_azurerm
  location                 = var.location_azurerm
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_log_analytics_workspace" "main" {
  for_each = { for analytic in var.log_analytics_workspace : analytic.name => analytic }

  name                = each.key
  resource_group_name = var.resource_group_name_azurerm
  location            = var.location_azurerm
  sku                 = each.value.sku
  retention_in_days   = each.value.retention_in_days
}

resource "azurerm_monitor_diagnostic_setting" "example" {
  for_each = var.vm_ids

  name                       = "${each.key}-diagnostic-setting"
  target_resource_id         = each.value
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main["example-law"].id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_metric_alert" "main" {
  for_each = { for i in var.monitor_metric_alert : i.name => i }

  name                = each.key
  description         = each.value.description
  resource_group_name = var.resource_group_name_azurerm
  scopes              = [for key in each.value.scopes : var.vm_ids[key]]
  severity            = lookup(each.value, "severity", 1)

  target_resource_type     = each.value.target_resource_type
  target_resource_location = var.location_azurerm

  dynamic "criteria" {
    for_each = each.value.criteria
    content {
      metric_namespace = criteria.value.metric_namespace
      metric_name      = criteria.value.metric_name
      aggregation      = criteria.value.aggregation
      operator         = criteria.value.operator
      threshold        = criteria.value.threshold
    }
  }

  # action {
  #   action_group_id = 
  # }
}

# Done
resource "azurerm_monitor_action_group" "main" {
  for_each = { for action in var.azurerm_monitor_action_group : action.name => action }

  name                = each.key
  resource_group_name = var.resource_group_name_azurerm
  short_name          = each.value.short_name

  dynamic "email_receiver" {
    for_each = each.value.email_receiver

    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = email_receiver.value.use_common_alert_schema
    }
  }
}
