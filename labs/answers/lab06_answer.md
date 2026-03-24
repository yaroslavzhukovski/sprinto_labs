# Lab 06 Answer Key - Bastion and VMSS

## Expected objective

- Validate secure access path using Bastion.
- Perform safe VMSS scale-out/scale-in operations.

## Correct execution path

1. Confirm Bastion host is provisioned and healthy.
2. Use Bastion session to access target VM without opening extra inbound internet ports.
3. Scale VMSS from 1 to 2 instances.
4. Validate instance health and provisioning.
5. Scale VMSS back to 1 to control cost.

## Success criteria

- Bastion access works.
- VMSS scales out and in successfully.
- Student can explain cost impact and why scale was rolled back.

## Required evidence

- Bastion connection screenshot.
- VMSS instance list before/after scale actions.
- Final VMSS instance count returned to 1.

## Common mistakes

- Trying to expose additional public access instead of Bastion.
- Forgetting to scale down and leaving unnecessary cost.

