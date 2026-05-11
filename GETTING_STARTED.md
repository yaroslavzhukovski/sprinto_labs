# Getting Started

Use this guide for your first setup and first deployment.

This file is intentionally detailed and beginner-friendly. Follow the steps in order.

## What You Will Do

You will:

1. install the required tools
2. sign in to Azure
3. prepare `platform/terraform.tfvars`
4. create an SSH key
5. deploy the healthy baseline
6. apply a lab scenario
7. destroy the environment when finished

## Before You Start

You need:

- your own Azure subscription for the course
- permission to create resources in that subscription
- a local copy of this repository

Important:

- each student should use their own subscription
- do not share one Terraform state between multiple students
- save your files before running Terraform commands

## Step 1 - Install the Required Tools

Install these tools:

1. Terraform CLI
2. Azure CLI
3. OpenSSH client (`ssh` and `ssh-keygen`)

Optional:

1. Git

Official installation guides:

- Terraform CLI: https://developer.hashicorp.com/terraform/install
- Azure CLI: https://learn.microsoft.com/cli/azure/install-azure-cli

## Step 2 - Check That the Tools Work

Open your terminal.

Recommended shells:

- Windows: PowerShell 7
- Linux: bash or zsh
- macOS: Terminal with zsh or bash

Run:

```bash
terraform version
az version
ssh -V
```

If one of these commands fails, stop and fix that first.

## Step 3 - Sign In to Azure

Run:

```bash
az login
```

After sign-in:

- make sure you are using the correct course subscription
- keep using the same Azure account for Terraform and Azure Portal

## Step 4 - Find Your Subscription ID and Tenant ID

Open Azure Portal.

How to open Azure Portal:

1. open your web browser
2. go to `https://portal.azure.com`
3. sign in with the same Azure account you used for `az login`

Then find the values like this:

1. In the search bar at the top of Azure Portal, type `Subscriptions`
2. Click `Subscriptions` in the search results
3. You will see a list of subscriptions available to your account
4. Click your student subscription
5. In the `Overview` page for that subscription, find `Subscription ID`
6. Copy `Subscription ID`
7. In the same `Overview` page, find `Directory (tenant) ID`
8. Copy `Directory (tenant) ID`

If you do not see `Subscriptions`:

- use the search bar again
- or open the portal menu and look for `Subscriptions`
- if your account has no subscription assigned, ask your teacher before continuing

You will paste these values into `platform/terraform.tfvars`.

## Step 5 - Create Your SSH Key

The Linux VMs use your SSH public key.

Create the key once on your own machine and reuse it for all labs.

### Windows PowerShell

```powershell
ssh-keygen -t ed25519 -C "azure-lab" -f "$HOME\.ssh\azure-lab-ed25519"
Get-Content "$HOME\.ssh\azure-lab-ed25519.pub"
```

### Linux

```bash
ssh-keygen -t ed25519 -C "azure-lab" -f ~/.ssh/azure-lab-ed25519
cat ~/.ssh/azure-lab-ed25519.pub
```

### macOS

```bash
ssh-keygen -t ed25519 -C "azure-lab" -f ~/.ssh/azure-lab-ed25519
cat ~/.ssh/azure-lab-ed25519.pub
```

This prints your public key.

Important:

- copy the full public key line
- do not share the private key file

## Step 6 - Prepare `platform/terraform.tfvars`

1. Open `platform/terraform.tfvars.example`
2. Open `platform/terraform.tfvars`
3. Copy the needed structure or values from the example file
4. Fill in your own values

You will usually need:

- `subscription_id`
- `tenant_id`
- `admin_ssh_public_key`
- any other student-specific values used in the file

Example:

```hcl
subscription_id       = "00000000-0000-0000-0000-000000000000"
tenant_id             = "00000000-0000-0000-0000-000000000000"
student_id            = "student01"
admin_ssh_public_key  = "ssh-ed25519 AAAA... azure-lab"
```

Notes:

- `student_id` helps identify your resources more clearly
- each student can use a different `student_id`
- resource names also include a unique suffix based on your subscription

## Step 7 - Save `platform/terraform.tfvars`

Before you run Terraform, save the file.

How to save:

- Windows or Linux: press `Ctrl+S`
- macOS: press `Cmd+S`
- or use your editor menu: `File -> Save`

Do not continue until the file is saved.

## Step 8 - Deploy the Healthy Baseline

Open your terminal in the repository root, then run:

```bash
cd platform
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file=terraform.tfvars -out=tfplan.bin
terraform apply tfplan.bin
```

Why this order is used:

- `init` downloads the required providers
- `fmt` formats Terraform files
- `validate` checks syntax and configuration structure
- `plan` shows what Terraform will create
- `apply` creates the resources

After Step 8, the main setup is done.

This is the part students usually do only once at the beginning of the course.

For the next lessons, students do not need to repeat the full setup guide unless something was deleted, broken, or needs to be rebuilt from the beginning.

## Step 9 - Continue From the Lab Folder

After the baseline is deployed, move to the lab materials.

Start here:

- open [labs/README.md]
- find the current lab
- open the matching file in `labs/docs/`

The lab instructions should guide the next steps from there.

Before you run a lab scenario, confirm that the healthy baseline exists:

- confirm the deployment completed successfully
- open Azure Portal at `https://portal.azure.com`
- find your resource group
- confirm that the expected baseline resources exist

This is important because labs should start from a known healthy state.

## Step 10 - Apply a Lab Scenario

From this point, students should follow the current lab instructions.

Labs are applied after the healthy baseline already exists.

Example for Lab 1:

```bash
cd platform
terraform apply -var-file=../labs/tfvars/lab01_nsg.tfvars
```

Example for Lab 2:

```bash
cd platform
terraform apply -var-file=../labs/tfvars/lab02_routing.tfvars
```

Important:

- baseline first
- lab second
- observe the healthy state before changing it
- after the first setup, future lessons usually start from the lab instructions, not from this full guide

## Step 11 - Complete the Lab

Use the student instructions in `labs/docs/`.

Examples:

- `labs/docs/lab01.md`
- `labs/docs/lab02.md`
- `labs/docs/lab03.md`

Instructor answer keys are in `answers/`.

## Step 12 - Destroy the Environment

When you finish, destroy the environment to avoid unnecessary cost.

Use the variable file that matches the current deployed state.

Example if the baseline is still deployed:

```bash
cd platform
terraform destroy -var-file=terraform.tfvars
```

Example if Lab 1 is the current deployed state:

```bash
cd platform
terraform destroy -var-file=../labs/tfvars/lab01_nsg.tfvars
```

## Common Beginner Mistakes

### The file was edited but not saved

If Terraform behaves as if your changes did not happen, check that `platform/terraform.tfvars` was saved.

### Wrong subscription

If resources appear in the wrong place or Terraform fails with permission errors, confirm you are using the correct Azure subscription.

### Invalid SSH key

Make sure `admin_ssh_public_key` contains a valid single-line public key.

### Policy deny during deployment

The environment includes Azure Policy restrictions.

If something is denied, check:

- region
- VM size
- storage SKU
- allowed resource types

### Running a lab before the baseline

Always deploy the healthy baseline first.

## Where to Go Next

- Project overview: [README.md](/Users/yaros/Documents/LiaAzureLab/README.md)
- Lab overview: [labs/README.md](/Users/yaros/Documents/LiaAzureLab/labs/README.md)
- Lab instructions: `labs/docs/`
- Answer keys: `answers/`
