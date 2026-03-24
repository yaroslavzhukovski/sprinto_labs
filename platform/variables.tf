variable "subscription_id" {
  description = "Azure subscription ID for the student environment."
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID."
  type        = string
}

variable "location" {
  description = "The only allowed region in the baseline."
  type        = string
  default     = "swedencentral"
}

variable "student_id" {
  description = "Optional identifier used in names and tags."
  type        = string
  default     = "shared"
}

variable "environment" {
  description = "Environment label for tags."
  type        = string
  default     = "lab"
}

variable "admin_username" {
  description = "Admin username for Linux VMs."
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key used for VM access."
  type        = string
}

variable "alert_email" {
  description = "Email address for budget and monitoring alerts."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Extra tags to merge with baseline tags."
  type        = map(string)
  default     = {}
}

variable "monthly_budget_amount" {
  description = "Monthly spend budget for the subscription."
  type        = number
  default     = 20
}

variable "student_principal_object_id" {
  description = "Entra object ID of the student user/group for portal storage access."
  type        = string
  default     = ""
}
variable "lab_flags" {
  description = "Feature and fault toggles used by tfvars scenarios."
  type = object({
    break_nsg                = bool
    break_routing            = bool
    break_storage_rbac       = bool
    enable_private_endpoint  = bool
    break_private_dns        = bool
    disable_diagnostics      = bool
    enable_bastion           = bool
    enable_vmss              = bool
    public_storage_network   = bool
    public_key_vault_network = bool
  })
  default = {
    break_nsg                = false
    break_routing            = false
    break_storage_rbac       = false
    enable_private_endpoint  = false
    break_private_dns        = false
    disable_diagnostics      = false
    enable_bastion           = false
    enable_vmss              = false
    public_storage_network   = true
    public_key_vault_network = true
  }
}

