# Azure Learning Platform (Terraform, 2026)

Modern, repeatable, low-cost Azure training platform for a 2-3 month hands-on course.

## Prerequisites (install before first run)

Students must install these tools first:

1. Terraform CLI (recommended: 1.8+)
2. Azure CLI (`az`)
3. OpenSSH client (`ssh` and `ssh-keygen`)

Optional:

1. Git (to clone the repository)

Important:

- Azure providers are not installed manually.
- `terraform init` automatically downloads required providers from `versions.tf`.

## Install tools (official docs)

Use the official installation guides instead of pinned commands in this repo.
They always contain the most current steps for Windows, macOS, and Linux.

Required:

1. Terraform CLI: https://developer.hashicorp.com/terraform/install
2. Azure CLI: https://learn.microsoft.com/cli/azure/install-azure-cli
3. OpenSSH client (`ssh` and `ssh-keygen`)

## Preflight checks (run before `plan/apply`)

Run these commands and confirm they work:

```bash
terraform version
ssh -V
```

If these checks fail, Terraform runs will fail too.

## Find Subscription ID and Tenant ID in Azure Portal

Use Azure Portal (no Azure CLI required for this step):

1. Open Azure Portal and go to `Subscriptions`.
2. Open your student subscription.
3. Copy `Subscription ID` into `platform/terraform.tfvars` as `subscription_id`.
4. In the same subscription pane, copy `Directory (tenant) ID` into `platform/terraform.tfvars` as `tenant_id`.

## Why this exists

Students learn Azure operations by deploying real infrastructure with Terraform and then resolving intentionally introduced platform issues in Azure Portal/CLI.

## Core principles

- Each student uses a dedicated Azure subscription.
- Baseline stays small and inexpensive.
- Labs force diagnosis in Azure (NSG, routes, RBAC, private endpoint, monitoring), not only code edits.
- Governance is visible through Azure Policy deny/audit outcomes.

## Repository structure

- `platform/`: baseline Terraform deployment.
- `platform/modules/`: reusable module boundaries (network, compute, identity, storage, key vault, monitoring, governance).
- `labs/tfvars/`: scenario toggles.
- `labs/docs/`: lab instructions and success criteria.
- `policies/`: standalone policy JSON artifacts.
- `docs/`: architecture, runbooks, troubleshooting.
- `.github/workflows/terraform-ci.yml`: CI checks.

## Baseline resources

- Hub/spoke VNets with peering.
- Multiple subnets and route table.
- Two Linux VMs (B-series), managed identities.
- VM1 has a public IP for admin access; VM2 is private (access from VM1/Bastion).
- NSGs (some attached, one intentionally available for fault scenarios).
- Storage account and container.
- Key Vault with RBAC authorization.
- Log Analytics, diagnostic settings, action group, metric alert.
- Subscription policy initiative assignment and budget alert.

Naming note:
- Resource names include an automatic unique suffix derived from the subscription ID to reduce global-name collisions (for example Storage Account and Key Vault).

## Quick start (direct Terraform, recommended)

1. Edit `platform/terraform.tfvars` and fill your real values.
2. Optional remote state (Azure Storage):
   - Copy `platform/backend.azurerm.tf.example` to `platform/backend.azurerm.tf`
   - Copy `platform/backend.hcl.example` to `platform/backend.hcl`
   - Fill values in `platform/backend.hcl`
3. Run:

```bash
cd platform
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file=terraform.tfvars -out=tfplan.bin
terraform apply tfplan.bin
```

4. To tear down:

```bash
cd platform
terraform destroy -var-file=terraform.tfvars
```

## Baseline first, labs second

Start with baseline first, then switch to lab files.

Why:

1. Baseline proves the platform is healthy before introducing intentional faults.
2. If first deployment fails, you can separate setup issues from lab scenario issues.
3. Students see expected behavior first, then practice troubleshooting.

Example flow:

```bash
cd platform
terraform apply -var-file=terraform.tfvars
terraform apply -var-file=../labs/tfvars/lab01_nsg.tfvars
```

When destroying, use the same var file used in the last apply:

```bash
cd platform
terraform destroy -var-file=../labs/tfvars/lab01_nsg.tfvars
```

## Common startup failures (and fixes)

1. `terraform: command not found`
   - Terraform is not installed or not on `PATH`.
2. `az: command not found`
   - Azure CLI is not installed or not on `PATH`.
3. Authentication errors during `plan/apply`
   - Run `az login` and select the correct subscription.
4. `Error: building account...` or permission denied
   - Your account lacks RBAC rights on the target subscription.
5. SSH key variable errors
   - `admin_ssh_public_key` must be a valid single-line `.pub` key.
6. Policy deny errors
   - Deployment conflicts with course policy (location/SKU/type restrictions).

## Which shell to use

- Windows: use `PowerShell 7` (recommended).
- Linux: use your normal terminal (`bash`/`zsh`).
- macOS: use Terminal (`zsh` by default).

All Terraform commands in this repository work from those shells.

## SSH key setup by OS (`admin_ssh_public_key`)

`admin_ssh_public_key` must be a single-line public key value (starts with `ssh-ed25519` or `ssh-rsa`).
Generate this key pair once per student machine, then reuse it for all labs.

### Windows (PowerShell)

```powershell
ssh-keygen -t ed25519 -C "azure-lab" -f "$HOME\.ssh\azure-lab-ed25519"
Get-Content "$HOME\.ssh\azure-lab-ed25519.pub"
```

### Linux (bash/zsh)

```bash
ssh-keygen -t ed25519 -C "azure-lab" -f ~/.ssh/azure-lab-ed25519
cat ~/.ssh/azure-lab-ed25519.pub
```

### macOS (zsh/bash)

```bash
ssh-keygen -t ed25519 -C "azure-lab" -f ~/.ssh/azure-lab-ed25519
cat ~/.ssh/azure-lab-ed25519.pub
```

Copy the printed public key line into `platform/terraform.tfvars`:

```hcl
admin_ssh_public_key = "ssh-ed25519 AAAA... azure-lab"
```

Private key location (do not share this file):

- Windows: `$HOME\.ssh\azure-lab-ed25519`
- Linux/macOS: `~/.ssh/azure-lab-ed25519`

Public key location (safe to paste into tfvars):

- Windows: `$HOME\.ssh\azure-lab-ed25519.pub`
- Linux/macOS: `~/.ssh/azure-lab-ed25519.pub`

`student_id` is optional in this repository now. If omitted, Terraform uses a default value.

## Labs

- `lab01_nsg`: blocked access from NSG priority conflict.
- `lab02_routing`: broken egress from invalid next hop.
- `lab03_storage_rbac`: managed identity role insufficient.
- `lab04_private_endpoint_dns`: storage private access and DNS issue.
- `lab05_monitoring_alerts`: missing diagnostics and alert validation.
- `lab06_bastion_vmss`: bastion access and VMSS scale operations.

## 2026 Terraform standards used

- `required_version` and explicit provider constraints.
- Local state by default; optional Azure Storage backend via `backend.azurerm.tf` + `backend.hcl`.
- `.terraform.lock.hcl` should be committed.
- `init -> fmt -> validate -> plan -> apply` workflow.
- module-first layout with strict input/output contracts.

## References

- https://developer.hashicorp.com/terraform/language
- https://developer.hashicorp.com/terraform/cli/commands
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- https://learn.microsoft.com/en-us/azure/developer/terraform/
- https://learn.microsoft.com/en-us/azure/governance/policy/overview



