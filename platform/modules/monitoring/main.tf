resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${var.prefix}"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

locals {
  diagnostic_supported_keys = toset(["vm1", "vm2", "storage", "kv", "vmss"])
  diagnostic_targets = var.disable_diagnostics ? {} : {
    for k, v in var.monitor_resource_ids : k => v
    if contains(local.diagnostic_supported_keys, k)
  }
}

data "azurerm_monitor_diagnostic_categories" "target" {
  for_each    = local.diagnostic_targets
  resource_id = each.value
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = local.diagnostic_targets

  name                       = "diag-${each.key}"
  target_resource_id         = each.value
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.target[each.key].log_category_types
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.target[each.key].metrics
    content {
      category = enabled_metric.value
    }
  }
}

resource "azurerm_monitor_action_group" "email" {
  count = local.enable_action_group ? 1 : 0

  name                = "ag-${var.prefix}"
  resource_group_name = var.rg_name
  short_name          = "liaag"
  tags                = var.tags

  email_receiver {
    name          = "course-email"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_metric_alert" "vm1_cpu" {
  count = local.enable_action_group && contains(keys(var.monitor_resource_ids), "vm1") ? 1 : 0

  name                = "alert-${var.prefix}-vm1-cpu"
  resource_group_name = var.rg_name
  scopes              = [var.monitor_resource_ids.vm1]
  description         = "CPU > 80% for VM1."
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.email[0].id
  }
}
