# Lab 05 Answer Key - Diagnostics and Log Analytics Workspace

## Recommended instructor flow

1. Student deploys the healthy baseline first:

```bash
cd platform
terraform apply -var-file=terraform.tfvars
```

2. Student observes State A:
   - monitored resources exist
   - Log Analytics Workspace exists
   - Key Vault diagnostic settings exist
   - Storage account diagnostic settings exist
   - the workspace contains tables and some real data

3. Student applies the Lab 5 scenario:

```bash
cd platform
terraform apply -var-file=../labs/tfvars/lab05_monitoring_alerts.tfvars
```

4. Student observes State B:
   - monitored resources still exist
   - Log Analytics Workspace still exists
   - diagnostic settings are missing
   - the monitoring path is broken

5. Student restores diagnostics manually in Azure Portal.

## Main teaching point

This lab is about understanding:

`resource -> diagnostic setting -> Log Analytics Workspace`

Simple explanation:

- resources create monitoring data
- diagnostic settings send that data
- Log Analytics Workspace is the central place where the data is stored
- if diagnostic settings are missing, the workspace can still exist but the data path is broken

Important instructor note:

- if students open an old VM diagnostics extension page, redirect them back to Azure Monitor diagnostic settings
- this lab is not about the deprecated guest diagnostics extension
- use Key Vault first and then Storage account as the main diagnostic-settings examples
- mention VM Insights / Azure Monitor Agent only as a modern VM-monitoring note
- remind students that logs can take about `5 minutes` to appear after diagnostic settings are created or restored

## Expected observations

### State A - Healthy baseline

- Key Vault and Storage account exist.
- A Log Analytics Workspace exists.
- A diagnostic setting exists on the Key Vault.
- A diagnostic setting exists for the `blob` service under the Storage account diagnostic settings page.
- The workspace `Logs` area shows multiple tables.
- At least one table contains some real data.
- Students understand that data is stored in the workspace, not on the blob object itself.
- Students understand that blob logging is configured from the Storage account `Diagnostic settings` page by opening the `blob` entry, not by creating a setting on one individual container or blob.

### State B - Diagnostics missing

- The monitored resources still exist.
- The Log Analytics Workspace still exists.
- Diagnostic settings are missing from the Key Vault and Storage account.
- The problem is not that the workspace was deleted.
- The problem is that data is no longer being sent correctly.

## Root cause

With `disable_diagnostics = true`, diagnostic settings are intentionally not created.

The workspace still exists, but the monitoring path from the resources to the workspace is incomplete.

## Correct diagnosis path

1. Open the Storage account and Key Vault.
2. Check `Diagnostic settings` on those resources in the `Monitoring` section.
3. Start with Key Vault, then continue with the Storage account.
4. In the Storage account, use the `blob` entry on the `Diagnostic settings` page.
4. Open the Log Analytics Workspace.
5. Open `Logs`.
6. Observe that the workspace exists, but the resource-to-workspace configuration is missing in State B.

## Correct fix

1. Re-enable diagnostic settings on the required resources in Azure Portal.
2. Connect those settings to the existing Log Analytics Workspace.
3. Restore Key Vault first, then restore the Storage `blob` diagnostic setting from the Storage account `Diagnostic settings` page.
4. Wait about `5 minutes`.
5. Confirm the resources now have diagnostic settings again.
6. Confirm that logs start appearing again in Log Analytics Workspace.
7. It is helpful to create some Storage activity after restoring the Storage account setting, for example by uploading or deleting a blob.
8. Blob activity should appear in the `StorageBlobLogs` table once ingestion completes, often within about `5-10 minutes`.
9. Students should try to find the same operations they performed, such as upload, read, or delete.

## Alerts in this lab

Alerts are secondary in Lab 5.

Students should only understand:

- alerts exist in Azure Monitor
- alerts can be based on metrics
- alerts can be based on logs
- alerts depend on monitoring data being available

Students do not need to trigger, wait for, or validate alerts in this lab.

## Required evidence

- Screenshot of the Log Analytics Workspace resource.
- Screenshot of `Logs` showing multiple tables.
- Screenshot of at least one table with some data.
- Screenshot of Key Vault diagnostic settings in State A.
- Screenshot of the `blob` diagnostic setting in State A.
- Screenshot showing missing diagnostic settings in State B.
- Screenshot showing restored diagnostic settings after the fix.

## Common mistakes

- Looking only at the workspace and forgetting to inspect diagnostic settings on the source resources.
- Assuming that because the workspace exists, diagnostics must be working.
- Expecting logs to appear immediately after restoring diagnostic settings.
- Looking for a separate diagnostic setting on an individual blob instead of using the `blob` entry under the Storage account `Diagnostic settings` page.
- Not knowing that blob activity is usually found in the `StorageBlobLogs` table.
- Treating this lab as an alert-triggering lab instead of a diagnostics and observability lab.
