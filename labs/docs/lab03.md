# Lab 03 - Storage RBAC and SAS (Portal-Only)

## Goal

Practice normal blob operations first, then switch to a broken RBAC scenario and troubleshoot permissions in Azure Portal.

## Phase A - Baseline Mode (`platform`)

Instructor action:

```bash
cd platform
terraform apply -var-file=terraform.tfvars
```

Student tasks in Azure Portal:

1. Open the lab storage account and the `labs` container.
2. Upload a small test file (`baseline.txt`) in the container.
3. Open `Shared access signature` for the container and create a SAS with:
   - Allowed permissions: `Read`, `List`, `Write`, `Create`, `Delete`
   - Short expiry (for example 1 hour)
4. Use the SAS URL/token to validate access and then delete `baseline.txt`.
5. Upload a second file (`function-test.txt`) for workload validation.
6. Validate platform function/integration behavior (if enabled in your environment):
   - Check Function App `Monitor` or Log Analytics entries related to blob processing.

Expected result in baseline mode:

- Upload, list, and delete operations succeed.
- SAS-based operation works.
- Related function/integration processing is visible (where implemented).

## Phase B - Lab Mode (`lab03_storage_rbac`)

Instructor action:

```bash
cd platform
terraform apply -var-file=../labs/tfvars/lab03_storage_rbac.tfvars
```

Student tasks in Azure Portal:

1. Re-open the same storage account and `labs` container.
2. Try to upload `lab03-new.txt`.
3. Try to delete an existing blob.
4. Try to use the same SAS workflow as in baseline.
5. Record exact error messages and failed actions.

Expected failure pattern:

- Read/list may still work.
- Upload/delete fail with authorization errors.
- Shared-key SAS workflow is blocked in this lab mode.

## Troubleshooting and Fix

1. Open storage account `Access control (IAM)`.
2. Check your current data-plane role assignment at storage account scope.
3. Identify that only `Storage Blob Data Reader` is present.
4. Add `Storage Blob Data Contributor` for your user/group at storage account scope.
5. Wait RBAC propagation (typically a few minutes).
6. Retry upload and delete in the `labs` container.

## Questions to answer

1. Which actions worked in baseline but failed in lab mode?
2. Why does `Storage Blob Data Reader` allow list/read but not upload/delete?
3. Why did SAS behavior change between baseline and lab mode?
4. Which exact role and scope fixed the problem?

## Success criteria

- Student reproduces failure in lab mode.
- Student identifies missing role as root cause.
- Student restores write/delete capability by assigning `Storage Blob Data Contributor` at correct scope.
- Student explains control plane vs data plane permissions clearly.

## Required evidence

- Baseline screenshot: successful upload/delete or SAS operation.
- Lab screenshot: failed upload/delete with error.
- IAM screenshot before fix: `Storage Blob Data Reader`.
- IAM screenshot after fix: `Storage Blob Data Contributor`.
- Final screenshot: successful upload/delete after fix.
