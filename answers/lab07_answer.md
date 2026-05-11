# Lab 07 Answer Key - Azure Policy, Deny, Audit, and Compliance

## Recommended instructor flow

1. Student deploys the healthy baseline first:

```bash
cd platform
terraform apply -var-file=terraform.tfvars
```

2. Student opens Azure Policy and observes:
   - the lab policy assignment
   - the initiative
   - the included policy definitions

3. Student performs one deny example in Azure Portal:
   - recommended: try to create a storage account in a disallowed region
   - alternative: try to create a VM with a disallowed size

4. Student performs one audit example:
   - remove the storage diagnostic setting
   - review compliance behavior

5. Student restores the storage diagnostic setting.

## Main teaching point

This lab is about understanding the difference between:

- `deny`
- `audit`
- compliance

Simple explanation:

- `deny` blocks the action
- `audit` allows the action but reports the resource
- compliance shows whether resources follow policy rules

## Expected observations

### State A - Healthy baseline

- A policy assignment exists.
- The assignment uses an initiative.
- The initiative includes multiple policy definitions.
- Some policies are deny-based.
- Some policies are audit-based.

### State B - Deny in action

- The attempted deployment is blocked.
- Azure shows a policy-related error or denial message.
- The resource is not created successfully.

### State C - Audit / non-compliance

- The storage account still exists.
- Removing diagnostics is allowed.
- The resource should become non-compliant under the storage diagnostics audit policy.
- Compliance visibility may take time to refresh.

## Root cause / governance explanation

The lab environment includes a policy initiative that contains both deny and audit-style rules.

Result:

- deny rules prevent disallowed actions immediately
- audit rules allow the action but mark the result as non-compliant

## Correct explanation path

1. Open the policy assignment.
2. Open the initiative.
3. Review the included definitions and identify deny and audit examples.
4. Reproduce one deny example and explain why it was blocked.
5. Reproduce one audit example and explain why it was allowed but still reported.

## Correct restore path

1. Re-create the storage diagnostic setting on the storage account.
2. Confirm the storage account returns to the intended monitored design.
3. Review compliance information again after refresh.

## Good answers to the main lab questions

1. What is the difference between a policy definition, an initiative, and an assignment?
- A definition is one rule, an initiative is a group of rules, and an assignment applies that rule set to a scope.

2. What is the difference between `deny` and `audit`?
- `deny` blocks the action. `audit` allows the action but records non-compliance.

3. Why is a denied resource different from a non-compliant resource?
- A denied resource is blocked before successful creation or update. A non-compliant resource still exists, but it does not match the policy expectation.

4. Why did the storage account still exist in the audit example?
- Because the policy effect is audit-based, not deny-based.

5. Why do companies use Azure Policy?
- To enforce standards, reduce risky configurations, improve consistency, and make compliance visible.

## Required evidence checklist

- Screenshot of the policy assignment.
- Screenshot of the initiative and included policy definitions.
- Screenshot of a denied deployment or policy error.
- Screenshot of storage diagnostics before removal.
- Screenshot of storage diagnostics removed.
- Screenshot of compliance or policy details related to the audit example.

## Common mistakes

- Treating Azure Policy as if it only blocks actions.
- Looking only at the compliance page without first understanding the assignment and initiative.
- Expecting audit compliance results to refresh instantly.
- Forgetting to restore the storage diagnostic setting after the audit example.
