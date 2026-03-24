variable "rg_name" {
  type        = string
  description = "Resource group for network resources."
}

variable "location" {
  type        = string
  description = "Azure location."
}

variable "prefix" {
  type        = string
  description = "Name prefix."
}

variable "tags" {
  type        = map(string)
  description = "Resource tags."
}

variable "lab_flags" {
  description = "Network-related lab toggles."
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
}
