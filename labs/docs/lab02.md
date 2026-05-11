# Lab 02 - Routing and Effective Routes

## Goal

Learn how a user-defined route (UDR) can break traffic between two private Azure networks even when the virtual machines and NSGs look healthy.

In this lab, you will:

1. start with a healthy private routing design
2. observe how it works
3. apply the Lab 2 routing change
4. observe what changed
5. compare the healthy state with the broken state
6. identify the bad next hop
7. fix the route and confirm the design works again

## What you should learn

After this lab, you should be able to:

- find which route table is associated to a subnet
- understand how a UDR changes packet flow
- use Azure Portal to inspect effective routes on a VM
- distinguish routing issues from NSG issues
- explain why a bad next hop causes private traffic failure

## Why this lab uses private traffic

For new Azure virtual networks created after March 31, 2026, private virtual machines should not be assumed to have automatic internet access.

Because of that, this lab uses private VM-to-VM traffic instead of public internet access.
That keeps the learning goal focused on routing itself.

## Before you start

Use the same Azure account for:

- Terraform
- Azure Portal

You will need:

- the public IP address of VM1
- the private IP address of VM1
- the private IP address of VM2
- the SSH private key that matches `admin_ssh_public_key`

Find the IP addresses:

```bash
cd platform
terraform output vm_public_ips
terraform output vm_private_ips
```

## What "hub" and "spoke" mean in this lab

In Azure, a common design is:

- `hub`: the central virtual network
- `spoke`: a connected virtual network

In this lab:

- VM1 is in the `hub` virtual network
- VM2 is in the `spoke` virtual network

You do not need deep architecture knowledge for this lab.
Just remember:

- VM1 is in one virtual network
- VM2 is in another virtual network
- those two networks should be able to talk to each other over private IP addresses

## State A - Healthy private routing

### Step 1 - Create State A

Run:

```bash
cd platform
terraform apply -var-file=terraform.tfvars
```

### Step 2 - Observe State A

The easiest beginner-friendly way is:

1. load your SSH key into your local SSH agent
2. connect to VM1 with agent forwarding
3. connect from VM1 to VM2

This keeps your private key on your own computer.

#### Step 2a - Start your local SSH agent

If you use Bash, run:

```bash
eval "$(ssh-agent -s)"
```

If you use PowerShell, run:

```powershell
Get-Service ssh-agent
Start-Service ssh-agent
```

It is best to open PowerShell as Administrator for this step.

If PowerShell says the service is disabled, run:

```powershell
Set-Service -Name ssh-agent -StartupType Manual
Start-Service ssh-agent
```

If you are using macOS or Linux, make sure your SSH agent is running.

#### Step 2b - Add your private key to the SSH agent

General form:

```bash
ssh-add <path-to-private-key>
```

Use the path to the private key file you created during setup.

Bash example:

```bash
ssh-add /c/Users/<your-user>/.ssh/azure-lab-ed25519
```

PowerShell example:

```powershell
ssh-add "C:\Users\<your-user>\.ssh\azure-lab-ed25519"
```

macOS or Linux example:

```bash
ssh-add ~/.ssh/azure-lab-ed25519
```

Check that the key is loaded:

```bash
ssh-add -L
```

You should see your public key printed.

#### Step 2c - Connect from your computer to VM1 with agent forwarding

General form:

```bash
ssh -A -i <path-to-private-key> azureuser@<vm1-public-ip>
```

Use the same private key path you used with `ssh-add`.

Bash example:

```bash
ssh -A -i /c/Users/<your-user>/.ssh/azure-lab-ed25519 azureuser@<vm1-public-ip>
```

PowerShell example:

```powershell
ssh -A -i "C:\Users\<your-user>\.ssh\azure-lab-ed25519" azureuser@<vm1-public-ip>
```

macOS or Linux example:

```bash
ssh -A -i ~/.ssh/azure-lab-ed25519 azureuser@<vm1-public-ip>
```

If SSH asks whether you trust the host for the first time, type:

```text
yes
```

#### Step 2d - Connect from VM1 to VM2

From inside VM1, run:

```bash
ssh azureuser@<vm2-private-ip>
```

If this works, you are now logged in to VM2.

Why this method is used:

- your private key stays on your own computer
- VM1 uses your forwarded authentication temporarily
- you do not copy private key material to VM1

### Step 3 - Verify State A

From inside VM2, run:

```bash
ping -c 4 <vm1-private-ip>
nc -zv <vm1-private-ip> 22
```

Expected State A result:

- `ping` succeeds
- `nc -zv` succeeds

### Step 4 - Record State A

Write down:

- how VM2 reaches VM1 in the healthy state
- what commands succeeded

## State B - Broken route to the hub network

### Step 5 - Create State B

If you are still connected to VM2 or VM1, first exit the SSH session and return to your own computer terminal.

You may need to run `exit` more than one time:

- once to leave VM2 and return to VM1
- once again to leave VM1 and return to your own computer

Example:

```bash
exit
exit
```

Then, from your own computer terminal, run:

Run:

```bash
cd platform
terraform apply -var-file=../labs/tfvars/lab02_routing.tfvars
```

### Step 6 - Observe State B

After the apply finishes, return to the same VM2 session or reconnect if needed.

### Step 7 - Verify State B

From inside VM2, run the same commands again:

```bash
ping -c 4 <vm1-private-ip>
nc -zv <vm1-private-ip> 22
```

Expected State B result:

- `ping` fails or times out
- `nc -zv` fails to connect to port 22

## Compare State A and State B

### Step 8 - Explain what changed

Answer these questions before fixing anything:

1. What worked in State A but failed in State B?
2. Are the VMs still running?
3. Are the two virtual networks still connected?
4. If the VMs and networks still exist, what type of change might explain the failure?

## Diagnose the cause

### Step 9 - Check the route table

In Azure Portal:

1. Open the resource group.
2. Open VM2.
3. Go to `Networking`.
4. Identify which subnet VM2 is using.
5. Open that subnet.
6. Check which route table is associated with the subnet.

Look for a custom route that affects traffic from the VM2 network to the VM1 network.

### Step 10 - Check effective routes on VM2

Still in Azure Portal:

1. Open VM2.
2. Go to `Networking`.
3. Open `Effective routes`.
4. Review the routes carefully.

Look for:

- a route covering the VM1 network address space `10.10.0.0/16`
- a next hop type of `Virtual appliance`
- a next hop IP that does not exist in the environment

This is the root cause in the lab:
traffic for the VM1 network is being sent to a fake next hop.

## Return to healthy routing

### Step 11 - Fix the route

In Azure Portal, remove the bad custom route or correct it so traffic to the VM1 network no longer points to the fake appliance.

### Step 12 - Verify the restored state

From VM2, run again:

```bash
ping -c 4 <vm1-private-ip>
nc -zv <vm1-private-ip> 22
```

Expected restored result:

- `ping` succeeds
- `nc -zv <vm1-private-ip> 22` succeeds

## Optional advanced investigation - Network Watcher

This section is optional.

Use it if you want to see a more advanced Azure troubleshooting tool.

Network Watcher can help you understand where Azure sends traffic and why connectivity fails.

### Find Network Watcher in Azure Portal

1. Open Azure Portal at `https://portal.azure.com`
2. In the search bar at the top, type `Network Watcher`
3. Click `Network Watcher`

### Use the Next hop tool

For this lab, the most useful feature is `Next hop`.

It helps answer this question:

- if VM2 sends traffic to VM1, where will Azure send that traffic?

### Example

Use `Next hop` like this:

1. In `Network Watcher`, open `Next hop`
2. Select the same subscription as the lab
3. Select the resource group for the lab
4. Select VM2 as the source virtual machine
5. For destination IP address, enter the private IP of VM1
6. Run the check

### What to look for

In the broken lab state, look for:

- a next hop result that points to a virtual appliance
- or a result that shows traffic is not using the expected private path

In the healthy state after the fix, look for:

- a normal next hop result for the private path to VM1

This tool is not required for the main lab.

The main beginner method is still:

- check the route table
- check effective routes

But Network Watcher is useful because it gives you another Azure way to diagnose routing problems.

## Questions to answer

1. What is the difference between an NSG problem and a route problem?
2. Why did the bad route break private connectivity even though the two virtual networks were still connected?
3. Which address prefix and next hop caused the issue in your environment?
4. Why is private VM-to-VM traffic a better test for this lab than public internet access?

## Success criteria

- you can explain the difference between State A and State B
- you can identify the route table associated to the VM2 subnet
- you can explain which route broke the traffic
- you can explain why the bad next hop caused the failure
- you can restore connectivity from VM2 to VM1 private IP

## Clean up when the lab is finished

When you finish the lab:

1. exit the SSH session on VM2 if you are still connected
2. exit the SSH session on VM1 if you are still connected
3. return to your own computer terminal
4. destroy the lab environment to avoid extra Azure cost

You may need to run:

```bash
exit
exit
```

Then destroy the environment from the `platform` folder:

```bash
cd platform
terraform destroy -var-file=../labs/tfvars/lab02_routing.tfvars
```

Use the Lab 2 tfvars file for destroy because the current deployed state is the Lab 2 scenario.
