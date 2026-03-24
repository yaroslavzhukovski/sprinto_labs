variable "subscription_id" {
  type        = string
  description = "Azure subscription UUID or full resource ID (/subscriptions/<uuid>)."
}

variable "location" {
  type        = string
  description = "Allowed Azure location."
}

variable "alert_email" {
  type        = string
  description = "Email for budget alerts."
  default     = ""
}

variable "monthly_budget_amount" {
  type        = number
  description = "Monthly subscription budget."
  default     = 20
}
