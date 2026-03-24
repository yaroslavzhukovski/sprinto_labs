locals {
  enable_action_group = trimspace(var.alert_email) != ""
}
