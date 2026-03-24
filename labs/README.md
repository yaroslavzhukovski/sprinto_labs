# Labs

The baseline is stable. Labs inject faults by passing a lab-specific tfvars file that toggles `lab_flags`.

## Run a scenario

```bash
terraform -chdir=platform plan -var-file=../labs/tfvars/lab01_nsg.tfvars
terraform -chdir=platform apply -var-file=../labs/tfvars/lab01_nsg.tfvars
```

## Labs

- `lab01_nsg.tfvars`: NSG deny rule conflict.
- `lab02_routing.tfvars`: Bad UDR next hop.
- `lab03_storage_rbac.tfvars`: Incorrect storage role for VM1.
- `lab04_private_endpoint_dns.tfvars`: Private endpoint and DNS issues.
- `lab05_monitoring_alerts.tfvars`: Disabled diagnostics and alert gaps.
- `lab06_bastion_vmss.tfvars`: Bastion + VMSS operations.

## Instructor keys

Instructor-only answer material is in `labs/answers/`.
