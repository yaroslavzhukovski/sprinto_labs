# Lab 04 - Public vs Private Storage Access

## Goal

Learn the difference between public storage access and private storage access in Azure.

In this lab, you will:

1. start with a healthy public storage design
2. observe how it works
3. switch to a healthy private storage design
4. observe what changed
5. manually remove one DNS component
6. observe what breaks
7. restore the component and confirm the design works again

## What you should learn

After this lab, you should be able to:

- explain the difference between public access and private access
- identify the purpose of a private endpoint
- identify the purpose of a private DNS zone
- identify the purpose of a private DNS virtual network link
- explain why DNS matters even when the private endpoint resource already exists

## Before you start

Use the same Azure account for:

- Terraform
- Azure Portal

You will need:

- the storage account name
- access to Azure Portal
- SSH access to a VM in the lab environment

Find the storage account name:

```bash
cd platform
terraform output storage_account_name
```

## State A - Healthy public storage

### Step 1 - Create State A

Run:

```bash
cd platform
terraform init
terraform apply -var-file=terraform.tfvars
```

### Step 2 - Observe State A

In Azure Portal:

1. Open the resource group.
2. Open the storage account.
3. Open `Networking`.
4. Open `Private endpoint connections`.

### Step 3 - Connect to a VM

You will need a VM session later in the lab for `nslookup`.

For this lab, connect to VM1.

You can find the VM1 public IP in Azure Portal:

1. Open the resource group for the lab
2. Open VM1
3. On the `Overview` page, copy the public IP address

Default private key location if you followed the setup guide:

- Windows: `C:\Users\<your-user>\.ssh\azure-lab-ed25519`
- Linux: `~/.ssh/azure-lab-ed25519`
- macOS: `~/.ssh/azure-lab-ed25519`

If you created your SSH key in a different location, use that path instead.

Windows example:

```powershell
ssh -i "C:\Users\<your-user>\.ssh\azure-lab-ed25519" azureuser@<vm1-public-ip>
```

Linux or macOS example:

```bash
ssh -i ~/.ssh/azure-lab-ed25519 azureuser@<vm1-public-ip>
```

Important:

- use the private key file
- do not use the `.pub` file
- if SSH asks whether you trust the host for the first time, type `yes`

If login works, you know:

- VM1 is running
- the public IP works
- you are ready to test DNS from inside the lab environment

### Step 4 - Verify State A

In this step, you will confirm that the storage account is using public access.

#### Step 4.1 - Test access to the storage account

In Azure Portal:

1. Open the resource group.
2. Open the storage account.
3. Open `Containers`.
4. Open the `labs` container.

Try to:

- list the blobs
- upload a small test file

If this works, it means:

- the storage account is reachable
- access over the public endpoint is working

#### Step 4.2 - Check networking settings

Now go back to the main storage account page.

1. In the left menu, find:
   - `Security + networking`
2. Click:
   - `Networking`

You are now looking at how access to this storage account is controlled.

#### Step 4.3 - Observe public access

At the top of the `Networking` page, you will see:

- `Public network access`

It should currently be:

```text
Enabled from all networks
```

#### Step 4.4 - Understand what this means

This setting means:

- the storage account is currently reachable through its public Azure endpoint
- access is not limited to a private internal network path
- this is the public access design

You may also notice that this page allows other options, for example:

- public access disabled
- public access enabled only from selected networks

If `Selected networks` is used, Azure can restrict access to:

- specific IP addresses
- specific virtual networks

Do not change anything yet.

In State A, you are only observing how the public design works.

#### Step 4.5 - Check private endpoints

Stay in the same `Networking` area.

Now open:

- `Private endpoint connections`

Check what is there.

Expected result in State A:

- there are no private endpoints yet
- the list is empty

Also verify:

- there is no private DNS zone for storage yet

How to verify:

- in the resource group, confirm that `privatelink.blob.core.windows.net` does not exist yet

#### Step 4.6 - Test DNS from a VM

First, find the storage account name.

You can find it in Azure Portal:

1. Open the resource group for the lab
2. Open the storage account
3. On the `Overview` page, copy the storage account name

From inside VM1, run:

```bash
nslookup <storage-account-name>.blob.core.windows.net
```

Example:

```bash
nslookup stliashared0ef936.blob.core.windows.net
```

Example result in State A:

```text
Server:         168.63.129.16
Address:        168.63.129.16#53

Non-authoritative answer:
stliashared0ef936.blob.core.windows.net    canonical name = blob.sn1prdstr09a.store.core.windows.net.
Name:   blob.sn1prdstr09a.store.core.windows.net
Address: 20.x.x.x
```

Expected result in State A:

- the storage account name resolves to a public IP address

What this means:

- DNS is currently sending you to the normal public storage endpoint
- there is no private endpoint or private DNS path yet
- even from inside the VM network, the storage account still looks like a public service

Write this result down.
You will compare it later with State B.

#### Step 4.7 - Understand why this matters

At this moment:

- the storage account works through public access
- there is no private endpoint yet
- there is no private internal-only access path yet

A private endpoint is an important security feature because it allows access to the storage account from inside the Azure virtual network through a private path.

That means:

- the storage account can be used internally
- it can be closed to normal public access
- access becomes more controlled and more secure

This is the main idea of the lab:

- first understand public access
- then switch to private access
- then observe which Azure components are needed to make private access work

### Step 5 - Write down what State A looks like

Record:

- what exists in public mode
- what does not exist yet
- how you know the storage account is using the public path

## State B - Healthy private storage

### Step 6 - Create State B

If you are still connected to VM1, first exit the SSH session and return to your own computer terminal:

```bash
exit
```

Then run:

```bash
cd platform
terraform init
terraform apply -var-file=../labs/tfvars/lab04_private_endpoint_dns.tfvars
```

### Step 7 - Observe State B

In Azure Portal:

1. Open the same storage account.
2. Open `Networking`.
3. Open `Private endpoint connections`.
4. Open the private DNS zone `privatelink.blob.core.windows.net`.
5. Open `Virtual network links` inside that DNS zone.

### Step 8 - Verify State B

Verify these points:

- `storage public network access is disabled`
  How to verify:
  In `Networking`, confirm public network access is disabled.

- `a private endpoint is created for blob access`
  How to verify:
  In `Private endpoint connections`, confirm there is an approved blob private endpoint.

- `a private DNS zone is created`
  How to verify:
  In the resource group, confirm that `privatelink.blob.core.windows.net` exists.

- `the private DNS zone is linked to the VM network`
  How to verify:
  In the DNS zone `Virtual network links`, confirm that the hub virtual network used by VM1 is linked.

- `DNS from the VM resolves the storage account to a private IP`
  How to verify:
  If you are no longer connected to VM1, connect again and run:

  ```bash
  nslookup <storage-account-name>.blob.core.windows.net
  ```

  The result should show a private IP address, not a public address.

### Step 9 - Compare State A and State B

Answer these questions before changing anything else:

1. What changed after private access was enabled?
2. Which components are new in State B?
3. What does each new component do?
4. Why is a private endpoint alone not enough?

## State C - Manually break one component

### Step 10 - Create State C

In Azure Portal, remove only this component:

- the private DNS virtual network link for `privatelink.blob.core.windows.net`

Do not:

- delete the private endpoint
- delete the storage account
- change multiple components at once

### Step 11 - Observe State C

In Azure Portal:

1. Open the storage account.
2. Open `Private endpoint connections`.
3. Open the private DNS zone.
4. Open `Virtual network links`.

### Step 12 - Verify State C

From the VM, run the same command again:

```bash
nslookup <storage-account-name>.blob.core.windows.net
```

Then verify these points:

- `the private endpoint still exists`
  How to verify:
  In the storage account `Private endpoint connections`, confirm it is still present.

- `the private DNS zone may still exist, but the virtual network link is missing`
  How to verify:
  Open the private DNS zone and confirm the link is no longer there.

- `DNS from the VM is no longer correct for private access`
  How to verify:
  Compare the new `nslookup` result with the healthy private result from State B.

- `the intended private access design no longer works correctly`
  How to verify:
  Observe that the private endpoint resource still exists, but DNS no longer guides the VM correctly.

### Step 13 - Explain what changed

Answer these questions:

1. Which resource still exists?
2. Which component is now missing?
3. Why does the design stop working even though the private endpoint still exists?

## Return to healthy private design

### Step 14 - Restore the missing component

Re-create or restore the private DNS virtual network link in Azure Portal.

### Step 15 - Verify the restored state

Run again from the VM:

```bash
nslookup <storage-account-name>.blob.core.windows.net
```

Confirm:

- the storage account name resolves correctly to the private IP again
- the private design is healthy again

## Questions to answer

1. What is the difference between public storage access and private storage access?
2. What new components appeared when you moved from State A to State B?
3. What does the private endpoint do?
4. What does the private DNS zone do?
5. What does the private DNS virtual network link do?
6. Why did removing the DNS virtual network link break the design?
7. Why is it useful to test DNS from a VM inside the virtual network instead of from your laptop?

## Success criteria

- you can explain the difference between State A and State B
- you can identify the main components used for private access
- you can show that healthy private DNS resolves the storage account to the private path
- you can remove one DNS component and explain what breaks
- you can restore the component and confirm the design works again

## Cleanup

### Step 16 - Exit the VM and destroy the lab

If you are still connected to VM1, first exit the SSH session and return to your own computer terminal:

```bash
exit
```

Then destroy the lab environment:

```bash
cd platform
terraform destroy -var-file=../labs/tfvars/lab04_private_endpoint_dns.tfvars
```

