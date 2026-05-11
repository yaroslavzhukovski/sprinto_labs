# Lab 01 Answer Key - NSG Troubleshooting

## Recommended instructor flow

1. Deploy the healthy baseline first:

```bash
cd platform
terraform apply -var-file=terraform.tfvars
```

2. Confirm healthy behavior before introducing the lab fault:
   - student can SSH to VM1
   - from VM1, `ping <vm2-private-ip>` succeeds
   - from VM1, `nc -zv <vm2-private-ip> 22` succeeds

3. Apply the Lab 1 scenario:

```bash
cd platform
terraform apply -var-file=../labs/tfvars/lab01_nsg.tfvars
```

4. Confirm the broken state:
   - student can still SSH to VM1
   - from VM1, `ping <vm2-private-ip>` fails
   - from VM1, `nc -zv <vm2-private-ip> 22` fails

## Expected symptom in lab state

- Student can SSH to VM1.
- From VM1, `ping <vm2-private-ip>` fails and `nc -zv <vm2-private-ip> 22` fails.

## Correct diagnosis path

1. Confirm VM1 and VM2 are running.
2. Confirm VM2 has no public IP and testing must be private path from VM1.
3. Check VM2 NIC effective security rules.
4. Check spoke subnet NSG association and rules.
5. Check hub subnet NSG outbound rules.

## Root cause

With `break_nsg = true`, deny rules are injected in multiple places:

- Spoke subnet NSG deny inbound
- Spoke NIC NSG deny inbound
- Hub subnet NSG deny outbound SSH to spoke subnet

This means the student may find more than one active blocker on the traffic path.

## Fix

1. Remove or disable the injected lab deny rules, or lower their precedence below the intended allow rules.
2. Verify the student is editing the NSGs that are actually attached to the VM2 subnet, VM2 NIC, or VM1 subnet path.
3. Keep least-privilege allow rules for the intended traffic path.
4. Re-test from VM1:
   - `ping <vm2-private-ip>`
   - `nc -zv <vm2-private-ip> 22`

Expected result after the fix:

- `nc -zv <vm2-private-ip> 22` succeeds
- `ping <vm2-private-ip>` succeeds if ICMP is also allowed by the final effective rules

## Required evidence

- Screenshot or terminal output showing healthy baseline connectivity before the lab fault.
- Screenshot of VM2 effective security rules.
- Screenshot of NSG association for spoke subnet and VM2 NIC.
- Screenshot of the relevant deny rule or rules before the fix.
- Terminal output of successful `ping` and `nc`.

## Common mistakes

- Investigating unattached decoy NSGs only.
- Checking only inbound or only outbound direction.
- Assuming one rule fix is enough when multiple deny points exist.
