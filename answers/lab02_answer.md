# Lab 02 Answer Key - Routing

## Recommended instructor flow

1. Deploy the healthy baseline first:

```bash
cd platform
terraform apply -var-file=terraform.tfvars
```

2. Confirm healthy behavior before introducing the lab fault:
   - student can connect to VM2 through VM1
   - from VM2, `ping <vm1-private-ip>` succeeds
   - from VM2, `nc -zv <vm1-private-ip> 22` succeeds

3. Apply the Lab 2 scenario:

```bash
cd platform
terraform apply -var-file=../labs/tfvars/lab02_routing.tfvars
```

4. Confirm the broken state:
   - student can still connect to VM2 through VM1
   - from VM2, `ping <vm1-private-ip>` fails
   - from VM2, `nc -zv <vm1-private-ip> 22` fails

## Expected symptom in lab state

- From VM2, traffic to VM1 private IP fails.
- `ping <vm1-private-ip>` fails.
- `nc -zv <vm1-private-ip> 22` fails.

## Correct diagnosis path

1. Verify NSGs are not the main blocker for the VM2 -> VM1 private path.
2. Inspect route table associated to spoke VM subnet.
3. Check effective routes on VM2.
4. Identify the custom route for the hub address space pointing to an invalid virtual appliance IP.

## Root cause

With `break_routing = true`, spoke route table sets:

- `10.10.0.0/16 -> VirtualAppliance 10.254.254.254`

This blackholes traffic from VM2 to the hub network.

## Fix

1. Remove the bad custom route or correct it so hub traffic no longer points to the fake appliance.
2. Re-test private connectivity from VM2 to VM1.

Expected result after the fix:

- `ping <vm1-private-ip>` succeeds
- `nc -zv <vm1-private-ip> 22` succeeds

## Required evidence

- Screenshot or terminal output showing healthy baseline connectivity before the lab fault.
- Screenshot/export of route table before and after.
- Effective routes view showing the bad route before the fix and the corrected path after the fix.
- Screenshot or terminal output showing failed connectivity in the broken lab state.
- Successful `ping` and `nc` test from VM2 to VM1 private IP after the fix.

## Common mistakes

- Editing NSGs while route table remains wrong.
- Forgetting route table association scope (subnet-level).
- Looking for internet egress problems even though this lab is now about private routing between two virtual networks.
