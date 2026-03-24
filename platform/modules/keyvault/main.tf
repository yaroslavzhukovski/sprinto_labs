resource "azurerm_key_vault" "this" {
  name                          = local.kv_name
  location                      = var.location
  resource_group_name           = var.rg_name
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  purge_protection_enabled      = false
  soft_delete_retention_days    = 7
  rbac_authorization_enabled    = true
  public_network_access_enabled = var.public_network_enabled
  tags                          = var.tags
}
