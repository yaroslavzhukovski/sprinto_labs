output "vnet_ids" {
  description = "Hub and spoke virtual network IDs."
  value = {
    hub   = azurerm_virtual_network.hub.id
    spoke = azurerm_virtual_network.spoke.id
  }
}

output "subnet_ids" {
  description = "Subnet IDs used by compute and private endpoint labs."
  value = {
    hub_vm                  = azurerm_subnet.hub_vm.id
    hub_bastion             = azurerm_subnet.hub_bastion.id
    spoke_vm                = azurerm_subnet.spoke_vm.id
    spoke_private_endpoints = azurerm_subnet.spoke_private_endpoints.id
  }
}

output "nsg_ids" {
  description = "NSG IDs for optional NIC associations."
  value = {
    hub_vm       = azurerm_network_security_group.hub_vm.id
    spoke_vm     = azurerm_network_security_group.spoke_nic.id
    spoke_subnet = azurerm_network_security_group.spoke_subnet.id
  }
}
