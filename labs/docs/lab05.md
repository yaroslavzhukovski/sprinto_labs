# Lab 05 - Diagnostics and Log Analytics Workspace

## Goal

Learn how Azure monitoring data reaches Log Analytics Workspace.

In this lab, you will:

1. start with a healthy monitoring design
2. observe where diagnostics are configured
3. observe where monitoring data is stored
4. apply the Lab 5 change that removes diagnostics
5. compare the healthy state with the broken state
6. restore the missing diagnostics

## What you should learn

After this lab, you should be able to:

- explain what a Log Analytics Workspace is
- explain what diagnostic settings do
- explain where monitoring data goes
- identify the difference between a resource existing and a resource sending monitoring data
- understand that monitoring data can be missing even when resources still exist

## Simple mental model

Use this idea throughout the lab:

`resource -> diagnostic setting -> Log Analytics Workspace`

Simple explanation:

- Log Analytics Workspace = central place where logs are stored
- Diagnostic settings = what sends data into the workspace
- Without diagnostics, the workspace can still exist, but data is not being sent into it

## Before you start

Use the same Azure account for:

- Terraform
- Azure Portal

You will need:

- access to Azure Portal

## Important note about old VM diagnostics

In Azure Portal, you may see an old VM page called `Diagnostic settings` that talks about the Azure Diagnostics extension.

This is not the main thing you should use in this lab.

For Lab 5, focus on:

- Azure Monitor diagnostic settings
- Log Analytics Workspace
- the monitoring path from the resource to the workspace

If you see an old VM diagnostics extension page, do not use it as the main lab check.

## Important note about time

After you create or restore diagnostic settings, logs do not always appear immediately.

In many cases, you need to wait about `5 minutes` before new data becomes visible in Log Analytics Workspace.

So in this lab:

- make the configuration change first
- wait a few minutes
- then check `Logs`

## State A - Healthy monitoring baseline

### Step 1 - Create State A

Run:

```bash
cd platform
terraform init
terraform apply -var-file=terraform.tfvars
```

### Step 2 - Observe State A

In Azure Portal:

1. Open the resource group.
2. Find the Log Analytics Workspace.
3. Open the workspace.
4. Open the main monitored resources for this lab:
   - Key Vault
   - Storage account

### Step 3 - Verify State A

In this step, first check Key Vault, then check the Storage account.

### Step 3.1 - Check Key Vault diagnostic settings

1. In the resource group, open the Key Vault.
2. In the left menu, find the `Monitoring` section.
3. Click `Diagnostic settings`.
4. Confirm that a diagnostic setting exists.
5. Open that diagnostic setting.
6. Click `Edit setting`.
7. Check where the data is sent.

Expected result:

- a diagnostic setting exists
- it sends data to the Log Analytics Workspace

This shows:

- the Key Vault is a source of monitoring data
- the Log Analytics Workspace is the destination

On the `Edit setting` page, notice that you can choose:

- which types of logs and metrics you want to collect
- where you want to send that data

In this lab, the important destination is the Log Analytics Workspace.

If you want, you can also look through the available log and metric types and change the selection.

This is optional.

For the main lab flow, it is enough to understand that this page controls:

- what data is collected
- where that data is sent

### Step 3.2 - Check Storage account diagnostic settings

1. Go back to the resource group.
2. Open the Storage account.
3. In the left menu, find the `Monitoring` section.
4. Click `Diagnostic settings`.
5. On this page, look at the list of resources.
6. Notice that you can see entries such as:
   - the Storage account itself
   - `blob`
   - `queue`
   - `table`
   - `file`
7. Click `blob`.
8. Confirm that the blob diagnostic setting exists, or create it if it is missing.
9. Open the blob diagnostic setting.
10. Click `Edit setting`.
11. Check which log categories are selected.
12. Check where the data is sent.

Expected result:

- a blob diagnostic setting exists
- it sends data to the same Log Analytics Workspace

Important:

- in this lab, the diagnostic setting for blob activity is managed from the Storage account `Diagnostic settings` page
- you do not create a separate diagnostic setting on one individual container or one individual blob
- instead, you open the `blob` entry under the Storage account and configure logging for blob service activity there

On the `Edit setting` page, notice that you can choose:

- which types of logs and metrics you want to collect
- where you want to send that data

In this lab, the important destination is the same Log Analytics Workspace.

If you want, you can also look through the available log and metric types and change the selection.

This is optional.

For the main lab flow, it is enough to understand that this page controls:

- what data is collected
- where that data is sent

### Step 3.3 - Open Log Analytics Workspace

Now confirm where the data goes.

1. Go back to the resource group.
2. Open the Log Analytics Workspace.
3. In the left menu, click `Logs`.
4. Wait for the Logs page to load.
5. Inside the `Logs` page, click the `Tables` icon to see the available tables.
6. Look through the list of tables.
7. Choose one table you want to inspect.

You should now see:

- the query area
- a list of tables
- a left-side or center panel where available tables are shown

Important:

- use the `Tables` icon inside the `Logs` page
- do not use the separate `Tables` item under `Settings`
- the `Tables` view inside `Logs` helps you explore actual available tables for querying

### Step 3.4 - Check that tables exist

1. In the `Logs` page, confirm that there are multiple tables.
2. Open at least one table from the `Tables` list.

If Azure opens a sample query for the table:

1. keep the query as it is
2. click `Run`

Expected result:

- you can see at least some records

### Step 3.5 - Understand what you are seeing

This is the key idea of State A:

- the resources exist
- diagnostic settings exist
- data is sent into Log Analytics Workspace
- the workspace stores that monitoring data in tables

Important:

- in this lab, the main idea is Azure Monitor diagnostic settings that send data to Log Analytics Workspace
- for virtual machines, Azure monitoring now more often uses Azure Monitor Agent, Data Collection Rules, and VM Insights onboarding
- do not use the deprecated VM guest diagnostics extension page as the main check for this lab

### Step 4 - Understand State A

Write down:

- the name of the Key Vault diagnostic setting
- the name of the Storage account diagnostic setting
- which resources have diagnostic settings
- the name of the Log Analytics Workspace
- at least one table you saw in the workspace
- what this tells you about where monitoring data is stored

Important idea:

- the workspace is the central place
- diagnostics are what send data there

## State B - Diagnostics missing

### Step 5 - Create State B

Run:

```bash
cd platform
terraform init
terraform apply -var-file=../labs/tfvars/lab05_monitoring_alerts.tfvars
```

### Step 6 - Observe State B

In Azure Portal:

1. Open the same Key Vault again.
2. Open `Monitoring` -> `Diagnostic settings`.
3. Open the same Storage account again.
4. Open `Monitoring` -> `Diagnostic settings`.
5. Open the same Log Analytics Workspace again.

### Step 7 - Verify State B

Verify these points:

- `the resources still exist`
  How to verify:
  Confirm the Key Vault and Storage account are still present.

- `the Log Analytics Workspace still exists`
  How to verify:
  Open the same workspace resource.

- `diagnostic settings are missing`
  How to verify:
  On the Key Vault and Storage account, open `Diagnostic settings` in the `Monitoring` section and confirm the settings are no longer present.

- `the central workspace exists, but the data path from resources is broken`
  How to verify:
  Compare the existing workspace with the missing diagnostic settings on the Key Vault and Storage account.

## Compare State A and State B

### Step 8 - Explain what changed

Answer these questions before fixing anything:

1. Which resources still exist in State B?
2. Does the Log Analytics Workspace still exist in State B?
3. What is missing in State B?
4. Why can monitoring data be missing even when both the resources and the workspace still exist?

This is the key lesson of the lab.

## Return to healthy monitoring

### Step 9 - Fix the problem

In Azure Portal, manually re-enable diagnostic settings on the required resources.

At minimum, inspect and restore diagnostics for:

- Key Vault
- Storage account

Connect them to the existing Log Analytics Workspace.

Important:

- use Azure Monitor diagnostic settings
- do not use the deprecated VM guest diagnostics extension page as the fix for this lab

### Step 9.1 - Restore Key Vault diagnostic settings

1. Open the Key Vault.
2. In the left menu, click `Monitoring` -> `Diagnostic settings`.
3. Click `Add diagnostic setting`.
4. Enter a name.
5. Select the available logs and metrics you want to send.
6. In the destination section, select the existing Log Analytics Workspace.
7. Save the diagnostic setting.

### Step 9.2 - Restore Storage account diagnostic settings

1. Open the Storage account.
2. In the left menu, click `Monitoring` -> `Diagnostic settings`.
3. On the list of resources, click `blob`.
4. If a blob diagnostic setting is missing, click `Add diagnostic setting`.
5. Enter a name.
6. Select the available logs and metrics you want to send.
7. In the destination section, select the same existing Log Analytics Workspace.
8. Save the diagnostic setting.

Important:

- stay in the Storage account `Diagnostic settings` area and use the `blob` entry there
- you do not need to create a separate diagnostic setting on a container or a single blob object
- the main lab goal is to restore the resource-to-workspace path

### Step 9.3 - Generate some Storage activity

After restoring the Storage account diagnostic setting, create a little real activity so Azure has something to send to the workspace.

In Azure Portal:

1. Stay in the Storage account.
2. Open `Containers`.
3. Open the `labs` container.
4. Upload a small test file, or delete a test file that you no longer need.

Examples:

- upload a small `.txt` file
- delete an old test blob
- upload a file and then delete it

This gives Azure some Storage activity that can later appear in the logs.

Important:

- blob activity usually appears in the `StorageBlobLogs` table
- if the diagnostic setting is configured correctly, those records often appear within about `5-10 minutes`
- after the wait, try to find the same operations you performed, for example:
  - upload
  - delete
  - read

## VM monitoring note

Virtual machines are a special case in modern Azure monitoring.

If you look at a VM, you may see an old diagnostics extension page.
That is not the main focus of this lab.

For VMs, modern monitoring more often uses:

- Azure Monitor Agent
- Data Collection Rules
- VM Insights onboarding

This is useful to know, but it is not the main beginner task in Lab 5.

### Step 10 - Verify the restored state

After restoring diagnostics:

1. Open the Key Vault again and confirm its diagnostic setting is present.
2. Open the Storage account again and confirm its diagnostic setting is present.
3. Wait about `5 minutes` for new logs to appear.
4. Open the Log Analytics Workspace.
5. Click `Logs`.
6. Inside the `Logs` page, click the `Tables` icon.
7. Find and open the `StorageBlobLogs` table.
8. If Azure opens a sample query, keep it and click `Run`.
9. Look for records that match the operations you performed on the blob.
10. If needed, also open another table and compare.
11. Confirm that the workspace is again being used as the central place for monitoring data.
12. If you created a blob upload or delete action, check whether new Storage-related records begin to appear after the wait.

Note:

- You do not need advanced KQL in this lab.
- A simple visual confirmation of the workspace, tables, and configuration is enough.

## Alerts - Visual introduction only

This lab is not mainly about alerts, but you should know where they fit.

In Azure Portal:

1. Open `Monitor`.
2. Open `Alerts`.
3. Open any alert rule that exists in the lab environment.

Understand this simple idea:

- alerts can be based on metrics
- alerts can also be based on logs and queries
- alerts depend on monitoring data being available

You do not need to trigger or validate an alert in this lab.

## Questions to answer

1. What is a Log Analytics Workspace?
2. What do diagnostic settings do?
3. Why can the workspace still exist while monitoring data is missing?
4. Which resources should send diagnostics to the workspace in this lab?
5. Why is the chain `resource -> diagnostic setting -> Log Analytics Workspace` important?

## Success criteria

- you can explain what the Log Analytics Workspace is
- you can explain what diagnostic settings do
- you can show that State A has the full monitoring path
- you can show that State B breaks the monitoring path even though the resources still exist
- you can restore diagnostics so the configuration is healthy again

## Required evidence

- screenshot of the Log Analytics Workspace resource
- screenshot of `Logs` showing multiple tables
- screenshot of at least one table with some data visible
- screenshot of diagnostic settings on a monitored resource in State A
- screenshot showing missing diagnostic settings in State B
- screenshot showing restored diagnostic settings after the fix

## Cleanup

### Step 11 - Destroy the lab

When the lab is finished, return to your own computer terminal and destroy the environment:

```bash
cd platform
terraform destroy -var-file=../labs/tfvars/lab05_monitoring_alerts.tfvars
```

