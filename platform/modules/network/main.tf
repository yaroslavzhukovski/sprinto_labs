resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${var.prefix}-hub"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = ["10.10.0.0/16"]
  tags                = var.tags
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-${var.prefix}-spoke"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = ["10.20.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "hub_vm" {
  name                 = "snet-hub-vm"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [local.subnet_prefixes.hub_vm]
}

resource "azurerm_subnet" "hub_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [local.subnet_prefixes.bastion]
}

resource "azurerm_subnet" "spoke_vm" {
  name                 = "snet-spoke-vm"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [local.subnet_prefixes.spoke_vm]
}

resource "azurerm_subnet" "spoke_private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [local.subnet_prefixes.pe]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-spoke"
  resource_group_name       = var.rg_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-spoke-to-hub"
  resource_group_name       = var.rg_name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}

resource "azurerm_network_security_group" "hub_vm" {
  name                = "nsg-${var.prefix}-hub-vm"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  security_rule {
    name                       = "allow-ssh-any"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "spoke_subnet" {
  name                = "nsg-${var.prefix}-spoke-subnet"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  security_rule {
    name                       = "allow-ssh-from-hub"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = local.subnet_prefixes.hub_vm
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-icmp-from-hub"
    priority                   = 210
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = local.subnet_prefixes.hub_vm
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "spoke_nic" {
  name                = "nsg-${var.prefix}-spoke-nic"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  security_rule {
    name                       = "allow-ssh-from-hub-nic"
    priority                   = 220
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = local.subnet_prefixes.hub_vm
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-icmp-from-hub-nic"
    priority                   = 230
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = local.subnet_prefixes.hub_vm
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "decoy" {
  for_each = local.decoy_nsgs

  name                = "nsg-${var.prefix}-${each.key}"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = merge(var.tags, { purpose = "lab-decoy-unattached" })

  dynamic "security_rule" {
    for_each = each.value.rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_network_security_rule" "spoke_subnet_breaker" {
  count = var.lab_flags.break_nsg ? 1 : 0

  name                        = "deny-all-inbound-subnet-lab"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.spoke_subnet.name
}

resource "azurerm_network_security_rule" "spoke_nic_breaker" {
  count = var.lab_flags.break_nsg ? 1 : 0

  name                        = "deny-all-inbound-nic-lab"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.spoke_nic.name
}

resource "azurerm_network_security_rule" "hub_breaker" {
  count = var.lab_flags.break_nsg ? 1 : 0

  name                        = "deny-hub-to-spoke-ssh-lab"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = local.subnet_prefixes.spoke_vm
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.hub_vm.name
}

resource "azurerm_subnet_network_security_group_association" "hub_vm" {
  subnet_id                 = azurerm_subnet.hub_vm.id
  network_security_group_id = azurerm_network_security_group.hub_vm.id
}

resource "azurerm_subnet_network_security_group_association" "spoke_vm" {
  subnet_id                 = azurerm_subnet.spoke_vm.id
  network_security_group_id = azurerm_network_security_group.spoke_subnet.id
}

resource "azurerm_route_table" "spoke" {
  name                = "rt-${var.prefix}-spoke"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  route {
    name                   = "default-egress"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = var.lab_flags.break_routing ? "VirtualAppliance" : "Internet"
    next_hop_in_ip_address = var.lab_flags.break_routing ? "10.254.254.254" : null
  }
}

resource "azurerm_subnet_route_table_association" "spoke_vm" {
  subnet_id      = azurerm_subnet.spoke_vm.id
  route_table_id = azurerm_route_table.spoke.id
}
