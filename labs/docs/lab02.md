# Lab 02 - Routing and Effective Routes

## Scenario

A user-defined route in the spoke subnet sends `0.0.0.0/0` to a fake virtual appliance. Outbound internet calls from VM2 fail.

## Learning objectives

- Read route table configuration and effective routes.
- Distinguish NSG problems from routing problems.
- Validate next hop reasoning.

## Access VM2 first (required for testing)

VM2 is private. Connect through VM1.

Recommended (Windows PowerShell):

1. In PowerShell as Administrator (one-time setup):

```powershell
Set-Service -Name ssh-agent -StartupType Manual
Start-Service ssh-agent
Get-Service ssh-agent
```

2. In your normal PowerShell session:

```powershell
ssh-add C:\Users\<your-user>\.ssh\azure-lab-ed25519
ssh-add -L
ssh -A azureuser@<vm1-public-ip>
```

3. From VM1 to VM2:

```bash
ssh-add -L
ssh azureuser@<vm2-private-ip>
```

Fallback (no ssh-agent needed, run from local machine):

```powershell
ssh -o ProxyJump=azureuser@<vm1-public-ip> -o IdentityFile=C:\Users\<your-user>\.ssh\azure-lab-ed25519 -o IdentitiesOnly=yes azureuser@<vm2-private-ip>
```

## Student tasks

1. Test outbound connectivity from VM2 (use `curl`, package update, and DNS checks first).
2. Review route table associated to the spoke subnet.
3. Inspect VM2 effective routes to identify the bad next hop.
4. Correct the route and retest connectivity.

Suggested connectivity tests from VM2:

```bash
curl -I --http1.1 https://www.microsoft.com --max-time 10
nslookup microsoft.com
sudo apt-get update
ping -c 4 8.8.8.8
ping -c 4 <vm1-public-ip>
ping -c 4 <vm1-private-ip>
```

Notes:

- Expected before fix (`0.0.0.0/0 -> VirtualAppliance 10.254.254.254`): outbound `curl` and `apt-get update` fail from VM2.
- Expected after fix (`0.0.0.0/0 -> Internet`): outbound `curl` and `apt-get update` succeed from VM2.
- Public internet ping from private Azure VM can still fail even when routing is correct (ICMP is not a reliable success signal for this lab).
- Ping to VM1 can fail because VM1 NSG primarily allows SSH (TCP/22), not ICMP.

## Success criteria

- VM2 reaches public endpoints again.
- Student documents route before/after and observed next hop behavior.

## Post-lab questions

1. Why can VM2 not reach the public IP address of VM1?
2. Why can ping to public internet (for example `8.8.8.8`) fail even when outbound web/package traffic from VM2 works?
