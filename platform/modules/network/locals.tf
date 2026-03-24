locals {
  subnet_prefixes = {
    hub_vm   = "10.10.1.0/24"
    bastion  = "10.10.2.0/26"
    spoke_vm = "10.20.1.0/24"
    pe       = "10.20.2.0/24"
  }

  decoy_nsgs = {
    app = {
      rules = [
        {
          name                       = "allow-https-internet"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "deny-rdp-any"
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "3389"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
    db = {
      rules = [
        {
          name                       = "allow-sql-from-hub"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = local.subnet_prefixes.hub_vm
          destination_address_prefix = "*"
        },
        {
          name                       = "deny-sql-internet"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "Internet"
          destination_address_prefix = "*"
        },
        {
          name                       = "deny-all-inbound"
          priority                   = 400
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
    mgmt = {
      rules = [
        {
          name                       = "allow-ssh-corp"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "10.0.0.0/8"
          destination_address_prefix = "*"
        },
        {
          name                       = "allow-winrm-corp"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "5986"
          source_address_prefix      = "10.0.0.0/8"
          destination_address_prefix = "*"
        }
      ]
    }
    web = {
      rules = [
        {
          name                       = "allow-http"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "allow-https"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "deny-ssh"
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  }
}
