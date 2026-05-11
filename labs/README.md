# Labs

The baseline is stable.

Some labs introduce changes by applying a lab-specific `tfvars` file that toggles `lab_flags`.
Other labs are mainly Portal-based comparison, governance, or exploration labs built on top of the healthy baseline.

## Run a scenario

```bash
terraform -chdir=platform plan -var-file=../labs/tfvars/lab01_nsg.tfvars
terraform -chdir=platform apply -var-file=../labs/tfvars/lab01_nsg.tfvars
```

## Labs

- `lab01_nsg.tfvars`: NSG deny rule conflict.
- `lab02_routing.tfvars`: Bad UDR next hop.
- `lab03_storage_rbac.tfvars`: Incorrect storage role for VM1.
- `lab04_private_endpoint_dns.tfvars`: Private endpoint, private DNS, and public-vs-private access comparison.
- `lab05_monitoring_alerts.tfvars`: Disabled diagnostics and Log Analytics observability gap.
- `lab06_bastion_vmss.tfvars`: Bastion-based secure VM access and access design basics.
- `lab07_policy_governance`: Azure Policy assignment, deny vs audit, and compliance exploration.

## Instructor keys

Instructor-only answer material is in `labs/answers/`.
