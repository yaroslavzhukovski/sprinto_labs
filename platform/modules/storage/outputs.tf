output "storage_account_id" {
  description = "Storage account resource ID."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "Storage account name."
  value       = azurerm_storage_account.this.name
}

output "storage_blob_endpoint" {
  description = "Blob service endpoint."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "private_endpoint_id" {
  description = "Private endpoint ID when enabled."
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.storage_blob[0].id : null
}
