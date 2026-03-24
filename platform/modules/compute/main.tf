resource "azurerm_public_ip" "vm1" {
  name                = "pip-${var.prefix}-vm1"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "vm1" {
  name                = "nic-${var.prefix}-vm1"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_ids.hub_vm
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1.id
  }
}

resource "azurerm_network_interface" "vm2" {
  name                = "nic-${var.prefix}-vm2"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_ids.spoke_vm
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "vm2" {
  network_interface_id      = azurerm_network_interface.vm2.id
  network_security_group_id = var.nsg_ids.spoke_vm
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                            = "vm-${var.prefix}-1"
  resource_group_name             = var.rg_name
  location                        = var.location
  size                            = var.vm1_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.vm1.id]
  tags                            = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = local.vm_image.publisher
    offer     = local.vm_image.offer
    sku       = local.vm_image.sku
    version   = local.vm_image.version
  }

  os_disk {
    name                 = "osdisk-${var.prefix}-vm1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                            = "vm-${var.prefix}-2"
  resource_group_name             = var.rg_name
  location                        = var.location
  size                            = var.vm2_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.vm2.id]
  tags                            = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = local.vm_image.publisher
    offer     = local.vm_image.offer
    sku       = local.vm_image.sku
    version   = local.vm_image.version
  }

  os_disk {
    name                 = "osdisk-${var.prefix}-vm2"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_public_ip" "bastion" {
  count = var.enable_bastion ? 1 : 0

  name                = "pip-${var.prefix}-bastion"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "this" {
  count = var.enable_bastion ? 1 : 0

  name                = "bas-${var.prefix}"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  ip_configuration {
    name                 = "bastion-ip"
    subnet_id            = var.subnet_ids.hub_bastion
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "this" {
  count = var.enable_vmss ? 1 : 0

  name                = "vmss-${var.prefix}"
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = "Standard_B1s"
  instances           = 1
  admin_username      = var.admin_username
  tags                = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  source_image_reference {
    publisher = local.vm_image.publisher
    offer     = local.vm_image.offer
    sku       = local.vm_image.sku
    version   = local.vm_image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "nic-vmss"
    primary = true

    ip_configuration {
      name      = "ipconfig-vmss"
      primary   = true
      subnet_id = var.subnet_ids.spoke_vm
    }
  }

  identity {
    type = "SystemAssigned"
  }
}
