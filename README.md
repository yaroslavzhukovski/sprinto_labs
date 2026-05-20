# Azure Learning Platform

Beginner-friendly Azure lab environment built with Terraform.

This repository is for students who are learning Azure, not advanced Terraform. Terraform is used here to create the same lab environment for every student, keep the labs repeatable, and make it easy to destroy and rebuild the environment between lessons.

If you are starting for the first time, read GETTING_STARTED.md and follow it step by step.

## What This Project Does

This project creates a small Azure platform that students can use for guided hands-on labs.

The normal learning flow is:

1. Deploy a healthy baseline environment.
2. Confirm that the baseline works.
3. Apply a lab scenario from `labs/tfvars/`.
4. Troubleshoot the issue in Azure Portal, Azure CLI, or from the VMs.
5. Fix the problem.
6. Destroy the environment when the lesson is finished.

The labs focus on Azure concepts such as:

- networking
- routing
- RBAC
- storage access
- private access
- diagnostics and monitoring
- Bastion
- Azure Policy and compliance

## Who This Is For

This repository is designed for beginners.

Assume that the student:

- is new to Azure
- may have little or no Terraform experience
- may need step-by-step instructions
- should be able to learn by comparing a healthy state with a changed or broken state

Because of that, the project aims to stay:

- simple
- low-cost
- predictable
- easy to teach
- easy to support

## Repository Structure

The repository is intentionally small.

- `platform/`
  The Terraform code for the baseline Azure environment.
- `platform/modules/`
  The Terraform modules used by the baseline platform.
- `labs/docs/`
  Student lab instructions.
- `labs/tfvars/`
  Lab scenario variable files that change the baseline into a specific lab state.
- `answers/`
  Instructor answer keys for the labs.
- `labs/README.md`
  Short lab overview.

## What Gets Deployed

The baseline platform includes:

- a hub and spoke virtual network design
- two Linux virtual machines
- network security groups
- route table
- storage account and blob container
- Key Vault
- managed identities and RBAC assignments
- Log Analytics Workspace
- diagnostic settings
- monitoring resources
- Azure Policy assignment
- budget configuration

Some labs also enable additional resources such as Azure Bastion.

Resource names include a unique suffix so that different students can deploy into separate subscriptions without common global-name conflicts.

## First-Time Setup

Use [GETTING_STARTED.md](/Users/yaros/Documents/LiaAzureLab/GETTING_STARTED.md) for the full step-by-step setup:

- install tools
- sign in to Azure
- prepare `platform/terraform.tfvars`
- create an SSH key
- run Terraform
- deploy the baseline
- apply labs
- destroy the environment

## Baseline First, Labs Second

Always deploy the healthy baseline first.

Why this matters:

- it proves the environment works
- it shows students what healthy behavior looks like
- it makes troubleshooting easier
- it separates deployment problems from lab problems

Example:

```bash
cd platform
terraform apply -var-file=terraform.tfvars
terraform apply -var-file=../labs/tfvars/lab01_nsg.tfvars
```

When you destroy the environment, use the same variable file that matches the current deployed state.

Example:

```bash
cd platform
terraform destroy -var-file=../labs/tfvars/lab01_nsg.tfvars
```

## Labs

The labs are designed to stay within a beginner-friendly range and usually focus on one main idea.

### Lab 1 - Network Security Groups

File:

- `labs/tfvars/lab01_nsg.tfvars`

Students learn:

- subnet NSG vs NIC NSG
- effective security rules
- how deny rules break connectivity

### Lab 2 - Routing

File:

- `labs/tfvars/lab02_routing.tfvars`

Students learn:

- route tables
- effective routes
- private connectivity between VNets
- how a wrong next hop breaks routing

### Lab 3 - Storage RBAC

File:

- `labs/tfvars/lab03_storage_rbac.tfvars`

Students learn:

- blob data-plane permissions
- read vs write actions
- why access can fail even when the storage account exists

### Lab 4 - Public vs Private Storage Access

File:

- `labs/tfvars/lab04_private_endpoint_dns.tfvars`

Students learn:

- public access vs private access
- private endpoint basics
- private DNS basics
- why DNS matters for private access

### Lab 5 - Diagnostics and Log Analytics

File:

- `labs/tfvars/lab05_monitoring_alerts.tfvars`

Students learn:

- what diagnostic settings do
- where logs are stored
- how Log Analytics Workspace is used
- why a workspace can exist while monitoring data is still missing

### Lab 6 - Azure Bastion

File:

- `labs/tfvars/lab06_bastion_vmss.tfvars`

Students learn:

- what Azure Bastion is
- why companies use it
- secure VM access over private networking
- Bastion in a hub-and-spoke design

### Lab 7 - Azure Policy

Student instructions:

- `labs/docs/lab07.md`

Students learn:

- policy definitions, initiatives, and assignments
- deny vs audit
- compliance vs non-compliance
- the difference between Azure Policy and RBAC

## Important Azure 2026 Networking Note

Azure networking behavior changed at the end of March 2026.

For new virtual networks created after March 31, 2026:

- subnets are private by default
- default outbound internet access should not be assumed

Because of that, this project avoids depending on implicit outbound access for the lab design.

## Common Problems

### `terraform` not found

Terraform is not installed or is not on your `PATH`.

### `az` not found

Azure CLI is not installed or is not on your `PATH`.

### Authentication errors during Terraform runs

Run:

```bash
az login
```

Then confirm you are using the correct subscription.

### Policy deny errors during deployment

The environment includes Azure Policy guardrails. If deployment is blocked, check:

- region
- VM size
- storage SKU
- allowed resource types

### SSH key errors

Make sure `admin_ssh_public_key` contains a valid single-line public key.

## Which Shell to Use

- Windows: PowerShell 7 is recommended
- Linux: bash or zsh
- macOS: Terminal with zsh or bash

## References

- Terraform language: https://developer.hashicorp.com/terraform/language
- Terraform CLI: https://developer.hashicorp.com/terraform/cli/commands
- AzureRM provider: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- Terraform on Azure: https://learn.microsoft.com/en-us/azure/developer/terraform/
- Azure Policy overview: https://learn.microsoft.com/en-us/azure/governance/policy/overview
