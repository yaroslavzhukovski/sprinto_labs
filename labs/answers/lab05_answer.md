# Lab 05 Answer Key - Monitoring and Alerts

## Expected symptom

- Telemetry is missing or incomplete.
- Expected alert does not trigger.

## Correct diagnosis path

1. Check diagnostic settings on VM/storage/key vault.
2. Confirm Log Analytics workspace linkage.
3. Validate action group exists and email receiver configured.
4. Inspect metric alert scope, metric, threshold, and evaluation period.

## Root cause

With `disable_diagnostics = true`, diagnostic settings are intentionally not applied.

## Fix

1. Re-enable diagnostics and apply.
2. Generate CPU load on VM1 to exceed threshold.
3. Verify alert fire state and notification path.

## Required evidence

- Diagnostic settings screenshot for monitored resources.
- Alert rule screenshot with fired state.
- Notification evidence (email or action group activity).

## Common mistakes

- Creating alert without valid action group.
- Verifying too quickly before evaluation window completes.

