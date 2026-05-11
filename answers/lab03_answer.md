# Lab 03 Answer Key - Storage RBAC and SAS

## Recommended instructor flow

1. Student runs the healthy baseline first:

```bash
cd platform
terraform apply -var-file=terraform.tfvars
```

2. Confirm healthy baseline behavior:
   - list works
   - read/download works
   - upload works
   - file can be downloaded back to student computer
   - direct blob URL without SAS fails
   - SAS URL for the uploaded blob works
   - `Allow storage account key access` is enabled in `Configuration`

3. Student applies the Lab 3 scenario:

```bash
cd platform
terraform apply -var-file=../labs/tfvars/lab03_storage_rbac.tfvars
```

4. Confirm the broken lab behavior:
   - list may still work
   - read/download may still work
   - upload fails
   - delete fails
   - SAS workflow based on shared key access is blocked

Important:

- this lab assumes the student runs Terraform with their own Azure account
- the same Azure account should be used in Terraform and Azure Portal

## Expected observations

### Baseline mode (`terraform.tfvars`)

- Blob list succeeds.
- Blob read/download succeeds.
- Blob upload succeeds.
- Blob can be downloaded back to the student computer.
- Direct blob URL without SAS fails because the blob is private.
- Blob-level SAS URL with `Read` permission succeeds.
- `Allow storage account key access` is enabled.

### Lab mode (`lab03_storage_rbac.tfvars`)

- Listing/reading blobs can still work.
- Upload and delete fail with authorization errors.
- SAS workflow used in baseline is no longer valid for write/delete operations in this mode.
- `Allow storage account key access` is disabled.

## Root cause

Lab mode changes storage security behavior and RBAC:

1. `break_storage_rbac = true` downgrades the student principal permissions for blob data to reader-only.
2. Shared-key based access is disabled in this mode, so key-based SAS access is blocked.

Result:

- the student can still perform some read-oriented actions
- the student can no longer perform write/delete data-plane operations until the blob data role is corrected
- shared-key based SAS behavior changes because `Allow storage account key access` is disabled in lab mode

Why this matters:

- shared key access allows Azure Storage to authorize requests by using the storage account key
- many SAS flows depend on that key-based model
- many companies disable it because they prefer Entra ID and RBAC over long-lived account keys

## Correct diagnosis path

1. Reproduce the failed actions in Portal.
2. Compare baseline actions against lab-mode actions.
3. Confirm the exact error in the Portal notification/details pane.
4. Open storage account `Configuration` and confirm `Allow storage account key access` is disabled.
5. Open storage account `Access control (IAM)`.
6. Check role assignment for the student principal at storage account scope.
7. Verify the role is `Storage Blob Data Reader`, which is insufficient for upload/delete.

## Correct fix

1. Add role assignment:
   - Role: `Storage Blob Data Contributor`
   - Scope: the target storage account
   - Principal: the student user account
2. Wait for RBAC propagation.
3. Retry upload and delete in Portal.

Expected post-fix result:

- Upload succeeds.
- Delete succeeds.
- Student can explain why the role change fixed data-plane operations.

## Complete answers to lab questions

1. Which actions worked in baseline but failed in lab mode?
- Upload and delete worked in baseline, then failed in lab mode due to reduced data-plane permissions.

2. Which actions still worked in lab mode, and why?
- List and read/download can still work because `Storage Blob Data Reader` allows read-oriented blob data actions.

3. Why does `Storage Blob Data Reader` fail for upload/delete?
- Reader is a read-only data-plane role. Upload/delete require write/delete permissions provided by contributor-level blob data roles.

4. Why did SAS behavior change?
- In lab mode, shared-key access is disabled. Students can no longer rely on key-based SAS in the same way, so access must be authorized through Entra ID RBAC.

5. Which role and scope fixed the issue?
- `Storage Blob Data Contributor` at storage account scope.

## Common mistakes and grading notes

- Using a different Azure account in Portal than the one used to run Terraform.
- Assigning `Owner` or `Contributor` control-plane access but forgetting the blob data-plane role.
- Fixing the role at the wrong scope.
- Retesting too quickly before RBAC propagation completes.
- Failing to compare baseline actions with lab-mode actions.

## Required evidence checklist

- Baseline success evidence for upload/read/download and SAS workflow.
- A simple comparison showing which actions worked in baseline and which failed in lab mode.
- Lab failure evidence showing authorization error on upload/delete.
- Configuration evidence showing shared key access enabled in baseline and disabled in lab mode.
- IAM before fix (`Storage Blob Data Reader`).
- IAM after fix (`Storage Blob Data Contributor`).
- Final successful upload/delete evidence.
