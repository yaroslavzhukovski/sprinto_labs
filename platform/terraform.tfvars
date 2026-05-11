subscription_id = "0ef93668-0595-4df1-96d9-76e3bfe3b38f"
tenant_id       = "a8ed5210-779f-4fa0-9b0c-a8568ecb77f3"
location        = "swedencentral"
admin_username  = "azureuser"

# Paste your full public key line from ~/.ssh/*.pub or $HOME\.ssh\*.pub
admin_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPY7SZom5elzn1r9Bw0mINpaBQRLdEQFV/vcpTESHrP3 azure-lab"

# Optional but recommended for alert notifications
alert_email           = "y.z@gmail.com"
monthly_budget_amount = 10


tags = {
  course = "azure-terraform-2026"
}









# Lab flags to enable/disable certain features for demo purposes.
lab_flags = {
  break_nsg                = false
  break_routing            = false
  break_storage_rbac       = false
  enable_private_endpoint  = false
  break_private_dns        = false
  disable_diagnostics      = false
  enable_bastion           = false
  enable_vmss              = false
  public_storage_network   = true
  public_key_vault_network = true
}
