output "resource_group_name" {
  description = "Platform resource group name."
  value       = azurerm_resource_group.platform.name
}

output "vnet_ids" {
  description = "Virtual network IDs."
  value       = module.network.vnet_ids
}

output "vm_public_ips" {
  description = "Public IPv4 addresses for VM access."
  value       = module.compute.vm_public_ips
}

output "vm_private_ips" {
  description = "Private IPv4 addresses for troubleshooting."
  value       = module.compute.vm_private_ips
}

output "storage_account_name" {
  description = "Storage account name."
  value       = module.storage.storage_account_name
}

output "key_vault_name" {
  description = "Key Vault name."
  value       = module.keyvault.key_vault_name
}

output "policy_assignment_id" {
  description = "Baseline governance policy assignment ID."
  value       = module.governance.policy_assignment_id
}

output "storage_private_endpoint_id" {
  description = "Storage private endpoint ID when enabled."
  value       = module.storage.private_endpoint_id
}
