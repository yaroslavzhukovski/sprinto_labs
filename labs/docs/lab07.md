# Lab 07 - Azure Policy, Deny, Audit, and Compliance

## Goal

Learn how Azure Policy affects real Azure operations.

In this lab, you will:

1. start with the healthy baseline
2. find the policy assignment in Azure Portal
3. see which rules are enforced
4. try an action that should be denied
5. create an audit-based non-compliance example
6. review compliance results
7. restore the environment to a healthy state

## What you should learn

After this lab, you should be able to:

- explain what Azure Policy is
- explain the difference between `deny` and `audit`
- explain what a policy assignment is
- explain what an initiative is
- explain what compliance and non-compliance mean
- find policy information in Azure Portal

## Simple explanation

Use this idea throughout the lab:

`policy definition -> initiative -> assignment -> effect on resources`

Simple meanings:

- Policy definition = one rule
- Initiative = a group of policy rules
- Assignment = where the rule or initiative is applied
- Deny = Azure blocks the action
- Audit = Azure allows the action, but reports non-compliance

## State A - Healthy baseline with governance

### Step 1 - Create State A

Run:

```bash
cd platform
terraform apply -var-file=terraform.tfvars
```

### Step 2 - Observe State A

In Azure Portal:

1. Open `Policy`.
2. Stay first on `Overview`.
3. Check the scope at the top of the page.
4. Then open `Assignments`.
5. Find the lab policy assignment.
6. Open the assignment.
7. From the assignment page, open `View initiative`.
8. Then go back and open `Definitions`.
9. Search for policy names that start with `lia-`.
10. Finally, open `Compliance`.

### Step 3 - Verify State A

In this step, use the Policy blade as a guided tour.

### Step 3.1 - Understand Overview

1. Open `Policy` and stay on `Overview`.
2. Check the scope shown near the top of the page.
3. Look at the compliance cards.

What this page means:

- this is the Policy dashboard
- it shows policy results for the current scope
- in this lab, the important scope is the subscription

Important:

- if the scope is wrong, the information you see may be confusing or incomplete
- for this lab, keep the scope at the subscription

### Step 3.2 - Open Assignments

1. In the left menu, click `Assignments`.
2. Find `LIA baseline guardrails assignment`.
3. Open it.

Check these points on the assignment page:

- the assignment name
- the scope
- `Definition type`
- `Policy enforcement`

What this means:

- assignment = Azure is applying a rule or a group of rules at a scope
- in this project, the assignment is applied to the subscription

Important note:

- if the `Parameters` tab looks empty, that is normal here
- it does not mean the assignment is broken
- it only means this assignment is not passing custom parameter values on that page

### Step 3.3 - Open the initiative

From the assignment page:

1. Click `View initiative`.
2. Review the list of included policy definitions.

What this means:

- initiative = a group of policy rules
- companies often assign initiatives instead of assigning every policy one by one

In this lab, try to find:

- at least one policy with the effect `deny`
- at least one policy with the effect `audit`

### Step 3.4 - Open Definitions

1. Go back to the main `Policy` blade.
2. Click `Definitions`.
3. Search for `lia-`.
4. Open one or two definitions.

What this means:

- definition = one policy rule
- this is the smallest building block in Azure Policy

Examples in this project:

- allowed locations
- allowed resource types
- audit storage diagnostics

### Step 3.5 - Open Compliance

1. Go back to the main `Policy` blade.
2. Click `Compliance`.
3. Keep the scope at the subscription.
4. Open the compliance results for `LIA baseline guardrails assignment`.

What this page means:

- this is where Azure shows the results of policy evaluation
- it shows which things are compliant
- it shows which things are non-compliant

Important note:

- the numbers can look larger than expected
- Azure Policy can count child resources and Azure-managed helper resources too
- so the compliance count is often larger than the number of main resources you remember creating

### Step 3.6 - Optional orientation only

In the left menu, you may also notice:

- `Exemptions`
- `Remediation`

Simple meanings:

- exemption = a policy is intentionally not applied to something
- remediation = Azure can sometimes help fix a policy problem

You do not need to use these deeply in this lab.

### Step 4 - Understand State A

Write down:

- what you saw on the `Overview` page
- the name of the policy assignment
- the name of the initiative
- what an assignment means in simple words
- what an initiative means in simple words
- what a definition means in simple words
- at least one policy that uses `deny`
- at least one policy that uses `audit`

## State B - Deny in action

### Step 5 - Create State B

In Azure Portal, try to create a resource that breaks one of the deny rules.

Recommended example:

- start creating a storage account
- choose a region outside the allowed region for the course

Alternative example:

- start creating a virtual machine
- choose a VM size outside the allowed list

### Step 6 - Observe State B

Watch what Azure does when you try to submit the deployment.

### Step 7 - Verify State B

Verify these points:

- `the deployment is denied`
  How to verify:
  The create operation should fail before the resource is created.

- `Azure shows that policy is the reason`
  How to verify:
  Read the error message and identify that Azure Policy blocked the action.

### Step 8 - Explain State B

Answer these questions:

1. What action did you try?
2. Which rule blocked it?
3. Why is `deny` different from a normal warning?

## State C - Audit and compliance

### Step 9 - Create State C

Now create a compliance example that is not denied but should become non-compliant.

Use the existing storage account from the baseline.

In Azure Portal:

1. Open the storage account.
2. Open `Diagnostic settings`.
3. Remove the diagnostic setting for the storage account.

Important:

- do not delete the storage account
- remove only the storage diagnostic setting

### Step 10 - Observe State C

In Azure Portal:

1. Open `Policy`.
2. Open `Compliance`.
3. Find the relevant storage diagnostics audit policy.

### Step 11 - Verify State C

Verify these points:

- `the storage account still exists`
  How to verify:
  Open the storage account and confirm it still exists.

- `the action was not denied`
  How to verify:
  You were able to remove the diagnostic setting.

- `the resource can become non-compliant`
  How to verify:
  In `Policy -> Compliance`, look for non-compliance related to missing storage diagnostics.

Important note:

- compliance results may not update immediately
- if results are delayed, the student should still understand the intended outcome: the resource is allowed to exist, but policy should report it as non-compliant

### Step 12 - Explain State C

Answer these questions:

1. Why was the storage account not blocked?
2. Why can it still be reported as non-compliant?
3. How is `audit` different from `deny`?

## Return to healthy compliance

### Step 13 - Restore the environment

Re-create the storage diagnostic setting so the storage account returns to the healthy baseline design.

### Step 14 - Verify the restored state

In Azure Portal:

1. Open the storage account.
2. Confirm the diagnostic setting exists again.
3. Open `Policy -> Compliance`.
4. Review the policy status again when data refresh is available.

## Questions to answer

1. What is the difference between a policy definition, an initiative, and an assignment?
2. What is the difference between `deny` and `audit`?
3. Why is a denied resource different from a non-compliant resource?
4. What did Azure Policy block in your deny example?
5. Why did the storage account still exist in the audit example?
6. Why do companies use Azure Policy?

## Success criteria

- you can find the policy assignment in Azure Portal
- you can explain what the initiative contains
- you can reproduce one deny example
- you can reproduce one audit/non-compliance example
- you can explain the difference between deny and audit in simple language

## Required evidence

- screenshot of the policy assignment
- screenshot of the initiative showing multiple policy definitions
- screenshot of a denied deployment or denied validation message
- screenshot of the storage account diagnostic setting before removal
- screenshot of the storage account after diagnostics were removed
- screenshot of the compliance view or policy details related to the audit example

## Cleanup

### Step 15 - Destroy the lab

When the lab is finished, return to your own computer terminal and destroy the environment:

```bash
cd platform
terraform destroy -var-file=terraform.tfvars
```
