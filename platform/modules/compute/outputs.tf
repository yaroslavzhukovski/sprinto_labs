output "vm_ids" {
  description = "VM resource IDs."
  value = {
    vm1 = azurerm_linux_virtual_machine.vm1.id
    vm2 = azurerm_linux_virtual_machine.vm2.id
  }
}

output "vm_principal_ids" {
  description = "System-assigned identity principal IDs for VMs."
  value = {
    vm1 = azurerm_linux_virtual_machine.vm1.identity[0].principal_id
    vm2 = azurerm_linux_virtual_machine.vm2.identity[0].principal_id
  }
}

output "vm_public_ips" {
  description = "VM public IP addresses."
  value = {
    vm1 = azurerm_public_ip.vm1.ip_address
    vm2 = null
  }
}

output "vm_private_ips" {
  description = "VM private IP addresses."
  value = {
    vm1 = azurerm_network_interface.vm1.private_ip_address
    vm2 = azurerm_network_interface.vm2.private_ip_address
  }
}

output "vmss_id" {
  description = "VMSS ID when enabled, otherwise null."
  value       = var.enable_vmss ? azurerm_linux_virtual_machine_scale_set.this[0].id : null
}
