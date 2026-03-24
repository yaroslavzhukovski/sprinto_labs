resource "azurerm_policy_definition" "allowed_locations" {
  name         = "lia-allowed-locations"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Allowed locations for student labs"
  description  = "Restrict resources to a single region for cost and governance."
  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "location"
          notIn = "[parameters('allowedLocations')]"
        },
        {
          not = {
            allOf = [
              {
                field  = "location"
                equals = "global"
              },
              {
                field = "type"
                in = [
                  "Microsoft.Insights/actionGroups",
                  "Microsoft.Insights/metricAlerts",
                  "Microsoft.Network/networkWatchers"
                ]
              }
            ]
          }
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
  parameters = jsonencode({
    allowedLocations = {
      type         = "Array"
      metadata     = { displayName = "Allowed locations" }
      defaultValue = [var.location]
    }
  })
}

resource "azurerm_policy_definition" "allowed_resource_types" {
  name         = "lia-allowed-resource-types"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed resource types for student labs"
  description  = "Allow only resource types used in this educational baseline."
  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          notIn = "[parameters('allowedResourceTypes')]"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
  parameters = jsonencode({
    allowedResourceTypes = {
      type         = "Array"
      metadata     = { displayName = "Allowed resource types" }
      defaultValue = local.allowed_resource_types
    }
  })
}

resource "azurerm_policy_definition" "allowed_vm_sizes" {
  name         = "lia-allowed-vm-sizes"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Allowed VM sizes (B-series)"
  description  = "Restrict VM sizes to low-cost B-series SKUs."
  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Compute/virtualMachines"
        },
        {
          field = "Microsoft.Compute/virtualMachines/sku.name"
          notIn = "[parameters('allowedVMSizes')]"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
  parameters = jsonencode({
    allowedVMSizes = {
      type         = "Array"
      metadata     = { displayName = "Allowed VM sizes" }
      defaultValue = ["Standard_B1s", "Standard_B1ms", "Standard_B2s"]
    }
  })
}

resource "azurerm_policy_definition" "allowed_storage_skus" {
  name         = "lia-allowed-storage-skus"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Allowed storage account SKUs (Standard only)"
  description  = "Restrict storage accounts to standard SKUs."
  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Storage/storageAccounts"
        },
        {
          field = "Microsoft.Storage/storageAccounts/sku.name"
          notIn = "[parameters('allowedStorageSkus')]"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
  parameters = jsonencode({
    allowedStorageSkus = {
      type         = "Array"
      metadata     = { displayName = "Allowed storage SKUs" }
      defaultValue = ["Standard_LRS", "Standard_GRS", "Standard_RAGRS", "Standard_ZRS", "Standard_GZRS", "Standard_RAGZRS"]
    }
  })
}

resource "azurerm_policy_definition" "audit_storage_tls_https" {
  name         = "lia-audit-storage-tls-https"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Audit storage HTTPS and TLS 1.2"
  description  = "Show non-compliance if HTTPS-only or TLS settings are weak."
  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Storage/storageAccounts"
        },
        {
          anyOf = [
            {
              field     = "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly"
              notEquals = true
            },
            {
              field     = "Microsoft.Storage/storageAccounts/minimumTlsVersion"
              notEquals = "TLS1_2"
            }
          ]
        }
      ]
    }
    then = {
      effect = "audit"
    }
  })
}

resource "azurerm_policy_definition" "audit_storage_diagnostics" {
  name         = "lia-audit-storage-diagnostics"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Audit storage diagnostics to Log Analytics"
  description  = "Show non-compliance when diagnostic settings are not configured for storage."
  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Storage/storageAccounts"
    }
    then = {
      effect = "auditIfNotExists"
      details = {
        type = "Microsoft.Insights/diagnosticSettings"
      }
    }
  })
}

resource "azurerm_policy_set_definition" "baseline" {
  name         = "lia-baseline-guardrails"
  policy_type  = "Custom"
  display_name = "LIA baseline guardrails"
  description  = "Subscription guardrails for the Azure learning platform."

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_locations.id
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_resource_types.id
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_vm_sizes.id
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_storage_skus.id
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.audit_storage_tls_https.id
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.audit_storage_diagnostics.id
  }
}

resource "azurerm_subscription_policy_assignment" "baseline" {
  name                 = "lia-baseline-guardrails-assignment"
  subscription_id      = local.subscription_resource_id
  policy_definition_id = azurerm_policy_set_definition.baseline.id
  display_name         = "LIA baseline guardrails assignment"
  description          = "Enforces low-cost educational guardrails."
  location             = var.location
}

resource "azurerm_consumption_budget_subscription" "monthly" {
  count = trimspace(var.alert_email) == "" ? 0 : 1

  name            = "lia-monthly-budget"
  subscription_id = local.subscription_resource_id
  amount          = var.monthly_budget_amount
  time_grain      = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00Z", timestamp())
  }

  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 80
    contact_emails = [var.alert_email]
  }

  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 100
    contact_emails = [var.alert_email]
  }
}
