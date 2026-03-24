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

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID."
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
