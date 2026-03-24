# Lab 03 Answer Key - Storage RBAC and SAS (Portal-Only)

## 1) Expected observations

### Baseline mode (`terraform.tfvars`)

- Blob upload to `labs` container succeeds.
- Blob delete succeeds.
- SAS-based operation succeeds.
- Blob-related platform function/integration check succeeds (if implemented in this tenant/lab build).

### Lab mode (`lab03_storage_rbac.tfvars`)

- Listing/reading blobs can still work.
- Upload and delete fail with authorization errors.
- SAS workflow used in baseline is no longer valid for write/delete operations in this mode.

## 2) Root cause

Lab mode changes storage security behavior and RBAC:

1. `break_storage_rbac = true` downgrades lab principal permissions for blob data to reader-only.
2. Shared-key based access is disabled in this mode, so key-based bypass is blocked.

Result:

- Student can no longer perform write/delete data-plane operations until role is corrected.

## 3) Correct diagnosis path

1. Reproduce failure in Portal (`Upload` and `Delete`).
2. Confirm exact error in the Portal notification/details pane.
3. Open storage account `Access control (IAM)`.
4. Check role assignment for student principal at storage account scope.
5. Verify role is `Storage Blob Data Reader` (insufficient for write/delete).

## 4) Correct fix

1. Add role assignment:
   - Role: `Storage Blob Data Contributor`
   - Scope: the target storage account (or target container scope if course allows that granularity)
   - Principal: student user/group
2. Wait for RBAC propagation.
3. Retry upload and delete in Portal.

Expected post-fix result:

- Upload succeeds.
- Delete succeeds.
- Student can explain why role change fixed data-plane operations.

## 5) Complete answers to lab questions

1. Which actions worked in baseline but failed in lab mode?
- Upload and delete worked in baseline, then failed in lab mode due to reduced data-plane permissions.

2. Why does `Storage Blob Data Reader` fail for upload/delete?
- Reader is read-only data-plane access. Upload/delete require write/delete permissions provided by contributor-level blob data roles.

3. Why did SAS behavior change?
- In lab mode, shared-key path is disabled and students cannot rely on key-based SAS bypass. Access must be authorized through Entra ID RBAC.

4. Which role and scope fixed the issue?
- `Storage Blob Data Contributor` at storage account scope (or equivalent container scope if explicitly used).

## 6) Common mistakes and grading notes

- Assigning `Owner`/`Contributor` (control plane) but forgetting blob data-plane role.
- Fixing role at wrong scope (different resource group/account).
- Retesting too quickly before RBAC propagation completes.
- Using account keys in baseline and assuming the same path is allowed in lab mode.

## 7) Required evidence checklist

- Baseline success evidence (upload/delete or SAS operation).
- Lab failure evidence (authorization error on upload/delete).
- IAM before fix (`Storage Blob Data Reader`).
- IAM after fix (`Storage Blob Data Contributor`).
- Final successful upload/delete evidence.
