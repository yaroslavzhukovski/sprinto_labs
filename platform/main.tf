resource "azurerm_resource_group" "platform" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.tags
}

module "network" {
  source     = "./modules/network"
  rg_name    = azurerm_resource_group.platform.name
  location   = var.location
  tags       = local.tags
  prefix     = local.name_prefix
  lab_flags  = var.lab_flags
  depends_on = [module.governance]
}

module "compute" {
  source               = "./modules/compute"
  rg_name              = azurerm_resource_group.platform.name
  location             = var.location
  tags                 = local.tags
  prefix               = local.name_prefix
  subnet_ids           = module.network.subnet_ids
  nsg_ids              = module.network.nsg_ids
  admin_username       = var.admin_username
  admin_ssh_public_key = var.admin_ssh_public_key
  enable_bastion       = var.lab_flags.enable_bastion
  enable_vmss          = var.lab_flags.enable_vmss
  depends_on           = [module.governance]
}

module "storage" {
  source                     = "./modules/storage"
  rg_name                    = azurerm_resource_group.platform.name
  location                   = var.location
  tags                       = local.tags
  prefix                     = local.name_prefix
  public_network_enabled     = var.lab_flags.public_storage_network
  disable_shared_key_auth    = var.lab_flags.break_storage_rbac
  enable_private_endpoint    = var.lab_flags.enable_private_endpoint
  break_private_dns          = var.lab_flags.break_private_dns
  private_endpoint_subnet_id = module.network.subnet_ids.spoke_private_endpoints
  private_dns_vnet_id        = module.network.vnet_ids.hub
  depends_on                 = [module.governance]
}

module "keyvault" {
  source                 = "./modules/keyvault"
  rg_name                = azurerm_resource_group.platform.name
  location               = var.location
  tags                   = local.tags
  prefix                 = local.name_prefix
  tenant_id              = var.tenant_id
  public_network_enabled = var.lab_flags.public_key_vault_network
  depends_on             = [module.governance]
}

module "identity" {
  source                      = "./modules/identity"
  storage_account_id          = module.storage.storage_account_id
  key_vault_id                = module.keyvault.key_vault_id
  vm_principal_ids            = module.compute.vm_principal_ids
  break_storage_rbac          = var.lab_flags.break_storage_rbac
  student_principal_object_id = var.student_principal_object_id
  depends_on                  = [module.governance]
}

module "monitoring" {
  source   = "./modules/monitoring"
  rg_name  = azurerm_resource_group.platform.name
  location = var.location
  prefix   = local.name_prefix
  tags     = local.tags
  monitor_resource_ids = merge(
    {
      vm1     = module.compute.vm_ids.vm1
      vm2     = module.compute.vm_ids.vm2
      storage = module.storage.storage_account_id
      kv      = module.keyvault.key_vault_id
    },
    module.compute.vmss_id == null ? {} : { vmss = module.compute.vmss_id }
  )
  disable_diagnostics = var.lab_flags.disable_diagnostics
  alert_email         = var.alert_email
  depends_on          = [module.governance]
}

module "governance" {
  source                = "./modules/governance"
  subscription_id       = var.subscription_id
  location              = var.location
  alert_email           = var.alert_email
  monthly_budget_amount = var.monthly_budget_amount
}

