# Platform Baseline

This folder contains the baseline Terraform deployment for each student subscription.

## What it deploys

- Resource group in `swedencentral`
- Hub/spoke virtual networks with peering
- Route table and NSGs (with optional fault toggles)
- Two Linux VMs (`Standard_B1s` and `Standard_B1ms`) with managed identities
- Storage account + blob container
- Key Vault (RBAC authorization, public access enabled by default)
- Log Analytics + diagnostic settings + sample metric alert
- Subscription policy definitions/initiative/assignment
- Monthly subscription budget alert

## Usage

```bash
cd platform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

To use Azure Storage remote state, create:

- `platform/backend.azurerm.tf` from `platform/backend.azurerm.tf.example`
- `platform/backend.hcl` from `platform/backend.hcl.example`

## References used for implementation patterns

- https://developer.hashicorp.com/terraform/language
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- https://learn.microsoft.com/en-us/azure/developer/terraform/
