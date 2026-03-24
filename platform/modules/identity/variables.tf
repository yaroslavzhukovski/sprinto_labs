variable "storage_account_id" {
  type        = string
  description = "Storage account resource ID."
}

variable "key_vault_id" {
  type        = string
  description = "Key Vault resource ID."
}

variable "vm_principal_ids" {
  type        = map(string)
  description = "Principal IDs keyed by VM name."
}

variable "break_storage_rbac" {
  type        = bool
  description = "When true, assign weaker storage role for VM1."
  default     = false
}

variable "student_principal_object_id" {
  type        = string
  description = "Student Entra object ID for portal storage RBAC lab."
  default     = ""
}
