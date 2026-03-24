resource "azurerm_role_assignment" "vm1_storage" {
  scope                = var.storage_account_id
  role_definition_name = local.vm1_storage_role
  principal_id         = var.vm_principal_ids.vm1
}

resource "azurerm_role_assignment" "student_storage" {
  scope                = var.storage_account_id
  role_definition_name = local.student_storage_role
  principal_id         = local.student_principal_id
}

resource "azurerm_role_assignment" "vm2_storage" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = var.vm_principal_ids.vm2
}

resource "azurerm_role_assignment" "vm1_key_vault" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.vm_principal_ids.vm1
}

resource "azurerm_role_assignment" "vm2_key_vault" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.vm_principal_ids.vm2
}

