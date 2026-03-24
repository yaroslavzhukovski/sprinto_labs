output "policy_set_definition_id" {
  description = "Policy initiative ID."
  value       = azurerm_policy_set_definition.baseline.id
}

output "policy_assignment_id" {
  description = "Policy assignment ID."
  value       = azurerm_subscription_policy_assignment.baseline.id
}

output "budget_id" {
  description = "Subscription budget resource ID."
  value       = trimspace(var.alert_email) == "" ? null : azurerm_consumption_budget_subscription.monthly[0].id
}
