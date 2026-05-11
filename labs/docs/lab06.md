# Lab 06 - Azure Bastion and Secure VM Access

## Goal

Learn how Azure Bastion provides secure access to virtual machines without requiring a public IP address on the target VM.

In this lab, you will:

1. start with the normal access design in the baseline
2. observe which VM has a public IP and which VM does not
3. enable Azure Bastion
4. observe the Bastion components in Azure Portal
5. connect to a VM through Bastion
6. explain why companies use Bastion instead of exposing management ports directly

## What you should learn

After this lab, you should be able to:

- explain what Azure Bastion is
- explain why Bastion is useful for secure VM access
- identify the Bastion host, Bastion subnet, and Bastion public IP
- explain why the target VM does not need a public IP
- explain how Bastion can still reach a VM over private networking
- understand at a high level which ports matter for Bastion and for the target VM

## Simple explanation

Azure Bastion is a managed Azure service for connecting to virtual machines over SSH or RDP through Azure Portal.

Simple idea:

- Bastion has the public entry point
- the target VM stays on private IP
- Bastion connects to the VM over the private network

This is why Bastion is often safer than giving every VM its own public management access.

## Before you start

Use the same Azure account for:

- Terraform
- Azure Portal

You will need:

- access to Azure Portal

## Important cost note

Azure Bastion is more expensive than many of the other resources in this project.

Because of that:

- do not leave this lab running longer than necessary
- destroy the environment as soon as you finish the lab

## State A - Baseline access design

### Step 1 - Create State A

Run:

```bash
cd platform
terraform apply -var-file=terraform.tfvars
```

### Step 2 - Observe State A

In Azure Portal:

1. Open the resource group.
2. Open VM1.
3. Open VM2.
4. Check the networking view for both VMs.

### Step 3 - Verify State A

Verify these points:

- `VM1 has a public IP`
  How to verify:
  Open VM1 and check its networking or overview pane.

- `VM2 does not have a public IP`
  How to verify:
  Open VM2 and confirm no public IP is assigned.

- `there is no Bastion host yet`
  How to verify:
  In the resource group, confirm there is no Bastion resource yet.

### Step 4 - Understand State A

Write down:

- which VM is directly reachable from the internet
- which VM is private only
- why a private-only VM is safer from a public exposure point of view

## State B - Bastion-enabled secure access

### Step 5 - Create State B

Run:

```bash
cd platform
terraform apply -var-file=../labs/tfvars/lab06_bastion_vmss.tfvars
```

### Step 6 - Observe State B

In Azure Portal:

1. Open the resource group.
2. Find the Bastion host resource.
3. Find the Bastion public IP.
4. Find the subnet named `AzureBastionSubnet`.
5. Open VM2.

### Step 7 - Verify State B

Verify these points:

- `a Bastion host exists`
  How to verify:
  Open the Bastion resource in the resource group.

- `the dedicated subnet AzureBastionSubnet exists`
  How to verify:
  Open the virtual network and confirm the subnet named `AzureBastionSubnet` exists.

- `Bastion has its own public IP`
  How to verify:
  Open the Bastion host and review its IP configuration.

- `the target VM still does not need a public IP`
  How to verify:
  Open VM2 and confirm it still has no public IP.

### Step 8 - Connect through Bastion

In Azure Portal:

1. Open VM2.
2. Select `Connect`.
3. Select `Bastion`.
4. Start a Bastion session.

Inside the Bastion session, try these tests:

1. Ping VM1 by using its private IP address.
2. Ping `google.com`.

Verify:

- you can reach the VM through Bastion
- the VM still does not need a public IP for this access method
- VM1 private connectivity is different from internet connectivity

What is the difference?

- when you ping VM1 by private IP, you are testing communication inside the Azure private network
- when you ping `google.com`, you are testing outbound access from the VM to the public internet

These are not the same path.

Important idea:

- a VM can communicate with another internal VM over private IP
- that does not automatically mean it is directly exposed to the internet
- Bastion gives you a secure way to reach the VM even though the VM itself stays private

## Compare State A and State B

### Step 9 - Explain what changed

Answer these questions:

1. What new components appeared in State B?
2. Which resource now has the public entry point?
3. Why does VM2 still not need a public IP?
4. Why is Bastion a safer design than exposing SSH directly on every VM?

## Bastion and different VNets

In this lab, Bastion is deployed in the hub virtual network.
VM2 is in the spoke virtual network.

Important idea:

- Bastion can be used with peered virtual networks
- that means one Bastion host can often serve VMs in another connected VNet

This is one reason many companies place Bastion in a hub network.

## High-level networking rules to understand

You do not need to memorize every rule, but you should understand the design:

- Bastion uses a dedicated subnet named `AzureBastionSubnet`
- Bastion uses a public entry point on port `443`
- the target VM is reached over the private network
- for Linux VMs, SSH on port `22` must be allowed from the Bastion path to the VM

Important:

- companies often prefer this model because they do not want to open SSH or RDP directly to the public internet on every VM

## Why companies use Bastion

Common reasons:

- reduce public exposure of virtual machines
- avoid public IPs on management targets
- centralize administrative access
- support browser-based access through Azure Portal
- use hub-and-spoke access patterns more safely

## Questions to answer

1. What is Azure Bastion?
2. Why does Bastion need its own subnet?
3. Why does VM2 not need a public IP when Bastion is used?
4. Why do many companies prefer Bastion to direct public SSH/RDP exposure?
5. How can Bastion still help reach a VM in another connected virtual network?
6. Which port is used for Bastion access from the user side, and which port is used on the Linux VM side?

## Success criteria

- you can identify the Bastion host and its supporting components
- you can connect to VM2 through Bastion
- you can explain why Bastion is safer than opening direct public management access
- you can explain at a simple level how Bastion uses public entry plus private VM connectivity

## Cleanup

### Step 10 - Close the Bastion session and destroy the lab

When you finish the lab:

1. Close the Bastion session in Azure Portal.
2. Return to your own computer terminal.

Then destroy the environment:

```bash
cd platform
terraform destroy -var-file=../labs/tfvars/lab06_bastion_vmss.tfvars
```
