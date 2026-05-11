resource "azurerm_storage_account" "this" {
  name                            = local.sa_name
  resource_group_name             = var.rg_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  public_network_access_enabled   = var.public_network_enabled
  shared_access_key_enabled       = !var.disable_shared_key_auth
  allow_nested_items_to_be_public = false
  tags                            = var.tags
}

resource "azurerm_storage_container" "labs" {
  name                  = "labs"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

resource "azurerm_private_dns_zone" "blob" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.rg_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_spoke" {
  count = var.enable_private_endpoint && !var.break_private_dns ? 1 : 0

  name                  = "link-spoke-blob"
  private_dns_zone_name = azurerm_private_dns_zone.blob[0].name
  resource_group_name   = var.rg_name
  virtual_network_id    = var.private_dns_vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "storage_blob" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "pe-${var.prefix}-blob"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "psc-${var.prefix}-blob"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.break_private_dns ? [] : [1]
    content {
      name                 = "default"
      private_dns_zone_ids = [azurerm_private_dns_zone.blob[0].id]
    }
  }
}

