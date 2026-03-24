# Lab 01 Answer Key - NSG Troubleshooting

## Expected symptom

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

## Fix

1. Remove or disable lab deny rules, or lower their precedence below intended allow rules.
2. Keep least-privilege allow rules (hub-to-spoke only).
3. Re-test from VM1:
   - `ping <vm2-private-ip>`
   - `nc -zv <vm2-private-ip> 22`

## Required evidence

- Screenshot of VM2 effective security rules.
- Screenshot of NSG association for spoke subnet and VM2 NIC.
- Terminal output of successful `ping` and `nc`.

## Common mistakes

- Investigating unattached decoy NSGs only.
- Checking only inbound or only outbound direction.
- Assuming one rule fix is enough when multiple deny points exist.

