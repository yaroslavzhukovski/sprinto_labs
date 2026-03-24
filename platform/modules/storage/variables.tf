variable "rg_name" {
  type        = string
  description = "Resource group name."
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

variable "public_network_enabled" {
  type        = bool
  description = "Whether public network access is enabled."
  default     = true
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Enable storage private endpoint resources."
  default     = false
}

variable "break_private_dns" {
  type        = bool
  description = "When true, intentionally skip DNS zone linkage."
  default     = false
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID used by storage private endpoint."
  default     = null
}

variable "private_dns_vnet_id" {
  type        = string
  description = "VNet ID linked to private DNS zone."
  default     = null
}

variable "disable_shared_key_auth" {
  type        = bool
  description = "Disable shared key auth to force Entra ID RBAC for blob operations."
  default     = false
}
