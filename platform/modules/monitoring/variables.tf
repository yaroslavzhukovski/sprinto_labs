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

variable "monitor_resource_ids" {
  type        = map(string)
  description = "Resources to attach diagnostic settings to."
}

variable "disable_diagnostics" {
  type        = bool
  description = "Disable diagnostic settings for lab troubleshooting."
  default     = false
}

variable "alert_email" {
  type        = string
  description = "Email used in action group."
  default     = ""
}
