data "azurerm_client_config" "current" {}

locals {
  vm1_storage_role     = var.break_storage_rbac ? "Storage Blob Data Reader" : "Storage Blob Data Contributor"
  student_storage_role = var.break_storage_rbac ? "Storage Blob Data Reader" : "Storage Blob Data Contributor"
  student_principal_id = var.student_principal_object_id != "" ? var.student_principal_object_id : data.azurerm_client_config.current.object_id
}
