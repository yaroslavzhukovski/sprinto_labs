# Lab 06 Answer Key - Azure Bastion and Secure VM Access

## Recommended instructor flow

1. Student deploys the healthy baseline first:

```bash
cd platform
terraform apply -var-file=terraform.tfvars
```

2. Student observes State A:
   - VM1 has a public IP
   - VM2 does not have a public IP
   - no Bastion host exists yet

3. Student applies the Lab 6 scenario:

```bash
cd platform
terraform apply -var-file=../labs/tfvars/lab06_bastion_vmss.tfvars
```

4. Student observes State B:
   - Bastion host exists
   - Bastion public IP exists
   - `AzureBastionSubnet` exists
   - VM2 still has no public IP

5. Student connects to VM2 using Bastion in Azure Portal.

## Main teaching point

This lab is about understanding secure access design.

Simple idea:

- Bastion provides the public entry point
- the target VM stays private
- Bastion reaches the VM over private networking

## Expected observations

### State A - Baseline

- VM1 has a public IP.
- VM2 is private only.
- There is no Bastion host yet.

### State B - Bastion enabled

- A Bastion host exists.
- A dedicated subnet named `AzureBastionSubnet` exists.
- Bastion has its own public IP.
- VM2 still does not need a public IP.
- Bastion can be used to reach the VM through Azure Portal.

## Correct diagnosis / explanation path

1. Open VM1 and VM2 and compare their networking settings.
2. Identify that VM2 has no public IP.
3. Open the Bastion resource and review its configuration.
4. Identify the `AzureBastionSubnet`.
5. Connect to VM2 through Bastion.
6. Explain why the Bastion host has the public entry point instead of the VM.

## Key concepts students should be able to explain

- Bastion is a managed secure access service.
- Bastion requires a dedicated subnet named `AzureBastionSubnet`.
- Bastion uses port `443` on the user side.
- Bastion reaches a Linux VM over private networking on port `22`.
- Bastion can support access across connected or peered VNets in a hub-and-spoke design.

## Required evidence

- Screenshot of VM2 showing no public IP.
- Screenshot of the Bastion host.
- Screenshot showing `AzureBastionSubnet`.
- Screenshot of a Bastion connection to VM2.

## Common mistakes

- Assuming the target VM must have a public IP.
- Trying to open extra public SSH access instead of using Bastion.
- Confusing the Bastion public entry point with a public IP on the target VM.
