# Lab 01 - NSG Troubleshooting

## Scenario

A deny-all rule was injected into active NSGs on the hub/spoke path. From VM1, connectivity to VM2 private IP fails.

## Learning objectives

- Interpret effective NSG rules.
- Compare subnet NSG vs NIC NSG behavior.
- Validate a fix with connectivity tests.

## Student tasks

1. SSH to VM1 using its public IP.
2. From VM1, test connectivity to VM2 private IP (`ping` and `nc -zv <vm2-ip> 22`).
3. Use Portal `Networking` and `Effective security rules` to find the blocking rule(s).
4. Remove or reprioritize deny rules so intended traffic is allowed.
5. Verify `ping` and `nc` both succeed and capture evidence.

## Success criteria

- VM2 private IP is reachable from VM1 using `ping` and TCP check with `nc`.
- Student can explain which NSG association/rule blocked traffic and why.
