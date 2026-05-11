# Lab 01 - NSG Troubleshooting

## Goal

Learn how Azure Network Security Groups (NSGs) affect traffic between two virtual machines.

In this lab, VM1 can be reached from the internet, but VM2 cannot be reached from VM1 over the private network until the NSG problem is fixed.

## Scenario

An intentional deny rule is added to active NSGs on the path between VM1 and VM2.

Because of that:

- VM1 is still reachable from the internet
- VM2 still exists and has a private IP
- traffic from VM1 to VM2 fails

Your task is to find the blocking NSG rule or rules in Azure Portal and fix the problem.

## What you should learn

After this lab, you should be able to:

- understand the difference between a subnet NSG and a NIC NSG
- check which NSG is actually attached to a resource
- use Azure Portal to inspect effective security rules
- test whether SSH and ICMP traffic are allowed or blocked
- explain why a higher priority deny rule can override an allow rule

## Before you start

This lab should be done in this order:

1. create the healthy baseline
2. observe the healthy baseline
3. apply the Lab 1 scenario
4. observe the broken state
5. investigate and fix the problem

This order is important.

Students should first see what healthy connectivity looks like before they troubleshoot the broken version.

You will need:

- the SSH private key that matches `admin_ssh_public_key`

Default private key location if you followed the setup guide:

- Windows: `C:\Users\<your-user>\.ssh\azure-lab-ed25519`
- Linux: `~/.ssh/azure-lab-ed25519`
- macOS: `~/.ssh/azure-lab-ed25519`

If you created your SSH key in a different location, use that path instead.

Important traffic path for this lab:

1. your computer -> VM1 public IP
2. VM1 -> VM2 private IP

VM1 is in the hub network.
VM2 is in the spoke network.

The hub and spoke networks are peered, so traffic should work when NSGs are configured correctly.

## State A - Healthy baseline

Run:

```bash
cd platform
terraform init
terraform apply -var-file=terraform.tfvars
```

Expected healthy behavior:

- VM1 and VM2 are deployed
- VM1 can reach VM2 over the private network
- there is no intentional NSG fault yet

### Connect to VM1

Windows example:

```powershell
ssh -i "C:\Users\<your-user>\.ssh\azure-lab-ed25519" azureuser@<vm1-public-ip>
```

Linux or macOS example:

```bash
ssh -i ~/.ssh/azure-lab-ed25519 azureuser@<vm1-public-ip>
```

If your key is in a custom location, replace the path with your real private key path.

Important:

- use the private key file
- do not use the `.pub` file
- if SSH asks whether you trust the host for the first time, type `yes`

If login works, you know:

- VM1 is running
- the public IP works
- the hub-side internet access to VM1 is not the main problem

### Test the healthy private path

From inside VM1, run:

```bash
ping -c 4 <vm2-private-ip>
nc -zv <vm2-private-ip> 22
```

What these commands mean:

- `ping` tests ICMP reachability
- `nc -zv` tests whether TCP port 22 is reachable

Expected result in State A:

- `ping` succeeds
- `nc -zv` succeeds

Write down the healthy result before you continue.

## State B - Broken NSG scenario

After State A is confirmed, apply the Lab 1 scenario:

If you are still connected to VM1, first exit the SSH session and return to your own computer terminal:

```bash
exit
```

Then run the Lab 1 Terraform command from the `platform` folder:

```bash
cd platform
terraform init
terraform apply -var-file=../labs/tfvars/lab01_nsg.tfvars
```

Expected result in State B:

- the same environment stays in place
- active NSG rules are changed
- VM1 can no longer reach VM2 private IP until the NSG problem is fixed

### Test the same path again

Go back to VM1 and run the same tests again:

```bash
ping -c 4 <vm2-private-ip>
nc -zv <vm2-private-ip> 22
```

Expected result in State B:

- `ping` fails or times out
- `nc -zv` fails to connect to port 22

Write down what you see.

Now you can compare:

- State A: healthy private connectivity
- State B: broken private connectivity

## Investigate

### Find where VM2 is connected

In Azure Portal:

1. Open the resource group for the lab environment.
2. Open VM2.
3. Go to `Networking`.
4. Identify:
   - which subnet VM2 is using
   - which network interface VM2 is using
   - whether a network security group is attached at subnet level
   - whether a network security group is attached at NIC level

Important:

Azure can enforce NSG rules in more than one place.
Do not assume there is only one NSG involved.

### Check effective security rules

Still in Azure Portal:

1. Open VM2.
2. Go to `Networking`.
3. Open `Effective security rules`.
4. Review inbound rules carefully.

Look for:

- deny rules with a lower priority number than allow rules
- rules that affect SSH on port `22`
- rules that affect ICMP
- whether the rule came from the subnet NSG or the NIC NSG

Remember:

- lower priority number = stronger rule
- `100` is evaluated before `200`
- a deny rule at a higher priority can block traffic even if an allow rule also exists

### Identify the blocking rule

Answer these questions:

1. Which NSG is active on the subnet?
2. Which NSG is active on the NIC?
3. Which deny rule is blocking VM1 -> VM2 traffic?
4. Is the block happening in one place or more than one place?

Do not change random NSGs in the resource group.

Only change the NSG rules that are actually attached to the traffic path.

## Fix and verify

### Fix the rule

Fix the blocking configuration in Azure Portal.

You can do this by:

- removing the blocking deny rule
- or changing its priority so the intended allow rule is evaluated first

Keep the learning goal in mind:

- traffic from VM1 to VM2 on SSH should be allowed
- unnecessary broad deny rules should not block the path

### Test again

After the change, go back to the VM1 SSH session and run the same tests again:

```bash
ping -c 4 <vm2-private-ip>
nc -zv <vm2-private-ip> 22
```

Expected result after the fix:

- `nc -zv <vm2-private-ip> 22` succeeds
- `ping` succeeds if ICMP is also allowed by the final effective rules

If `nc` works but `ping` still fails, review the effective rules again and check whether ICMP is still blocked.

## What to capture as evidence

Take screenshots of:

- successful connectivity test in State A
- successful SSH connection to VM1
- failed connectivity test in State B
- VM2 effective security rules showing the blocking rule
- the NSG rule after the fix
- successful connectivity test after the fix

## Success criteria

You have completed the lab when:

- you understand the difference between State A and State B
- VM1 is reachable by SSH from your machine
- VM2 private IP is reachable from VM1 on TCP port 22
- you can explain whether the problem was in the subnet NSG, NIC NSG, or both
- you can explain why the deny rule won over the allow rule

## Common mistakes

- editing an NSG that is not attached to the subnet or NIC
- looking only at the subnet NSG and forgetting the NIC NSG
- looking only at the NIC NSG and forgetting the subnet NSG
- forgetting that lower priority number means higher priority
- testing from your own machine to VM2 instead of from VM1 to VM2
- assuming the first rule you see is the rule that actually wins

## Reflection questions

Answer these after the lab:

1. What is the difference between a subnet NSG and a NIC NSG?
2. Why is `Effective security rules` more useful than only reading one NSG manually?
3. Which rule blocked the traffic in your environment?
4. Why did changing that rule restore connectivity?

## Clean up when the lab is finished

When you finish the lab:

1. exit the SSH session on VM1 if you are still connected
2. return to your own computer terminal
3. destroy the lab environment to avoid extra Azure cost

Exit VM1:

```bash
exit
```

Destroy the environment from the `platform` folder:

```bash
cd platform
terraform destroy -var-file=../labs/tfvars/lab01_nsg.tfvars
```

