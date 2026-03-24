# Lab 02 Answer Key - Routing

## Expected symptom

- From VM2, outbound internet calls fail (for example package updates or curl to public endpoints).

## Correct diagnosis path

1. Verify NSGs are not the blocker for outbound path.
2. Inspect route table associated to spoke VM subnet.
3. Check effective routes on VM2.
4. Identify default route to invalid virtual appliance IP.

## Root cause

With `break_routing = true`, spoke route table sets:

- `0.0.0.0/0 -> VirtualAppliance 10.254.254.254`

This blackholes egress.

## Fix

1. Change default route next hop back to `Internet` (or remove bad route).
2. Re-test outbound from VM2.

## Required evidence

- Screenshot/export of route table before and after.
- Effective routes view showing corrected default route.
- Successful outbound test from VM2.

## Common mistakes

- Editing NSGs while route table remains wrong.
- Forgetting route table association scope (subnet-level).

