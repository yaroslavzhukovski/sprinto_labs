# Lab 03 - Storage RBAC and SAS

## Goal

Learn how Azure Storage data-plane permissions affect real blob actions in Azure Portal.

In this lab, you will:

1. start with a healthy storage access state
2. observe what works
3. apply the Lab 3 RBAC change
4. observe what changed
5. compare which actions still work and which fail
6. fix the role assignment and confirm the result

## What you should learn

After this lab, you should be able to:

- tell the difference between read actions and write/delete actions
- understand that Azure RBAC can allow some blob actions and block others
- find the correct blob data role in `Access control (IAM)`
- explain the difference between control plane access and data plane access
- understand why disabling shared key access changes SAS behavior

## What SAS means in this lab

`SAS` means `Shared Access Signature`.

In simple words:

- SAS is a special storage link or token
- it gives temporary access to storage data
- the SAS can allow only specific actions
- for example:
  - read
  - list
  - write
  - create
  - delete

In State A, you will test that SAS can be created and used.

In State B, you will observe what changes when shared key access is disabled.

## State A - Healthy storage access

### Step 1 - Create State A

Run:

```bash
cd platform
terraform init
terraform apply -var-file=terraform.tfvars
```

### Step 2 - Find the storage account

After State A is created, find the storage account name.

Option 1 - Terraform output:

```bash
cd platform
terraform output storage_account_name
```

Option 2 - Azure Portal:

1. Open Azure Portal at `https://portal.azure.com`
2. Open the resource group for the lab environment
3. Find the storage account in the resource list

### Step 3 - Observe State A

In Azure Portal:

1. Open the resource group for the lab environment.
2. Open the storage account.
3. Open `Containers`.
4. Open the `labs` container.

### Step 4 - Verify State A

Test these actions in the healthy baseline:

1. List blobs in the `labs` container.
2. Create a small file on your own computer.
   It can be:
   - a text file
   - a document
   - a picture
3. Upload that file to the `labs` container.
4. Open or download the uploaded file in Azure Portal.
5. Download the file back to your own computer.
6. Keep the file in the container for the next checks.
   Do not delete it yet.
7. Click your uploaded blob.
8. Find the blob URL in the blob details view.
9. Copy the URL and open it in your browser.
10. Notice that direct browser access fails because the blob is private and the URL has no access token.
11. Stay on the same blob and open `Generate SAS`.
12. Look at the available permissions.
13. Select only `Read`.
14. Click `Generate SAS token and URL`.
15. Copy the generated SAS URL and open it in your browser.
16. Confirm that this SAS URL works.
17. Open the storage account `Configuration` page and find `Allow storage account key access`.
18. Notice that key access is enabled in State A.

What this shows in State A:

- the blob is not publicly available by default
- direct URL access without a token does not work
- SAS gives temporary controlled access to a specific blob
- this is one of the normal ways companies share private storage content safely
- key-based access is currently enabled, so this SAS workflow is available

Expected State A result:

- list works
- read/download works
- upload works
- download back to your computer works
- direct blob URL without SAS fails
- SAS workflow works

### Step 5 - Record State A

Write down:

- which actions work in the healthy baseline
- which access methods are available

## State B - Reduced blob permissions

### Step 6 - Create State B

Run:

```bash
cd platform
terraform init
terraform apply -var-file=../labs/tfvars/lab03_storage_rbac.tfvars
```

### Step 7 - Observe State B

After the apply finishes, return to the same storage account and the same `labs` container.

### Step 8 - Verify State B

Test the same kinds of actions again:

1. List blobs in the container.
2. Open or download an existing blob.
3. Upload a new file called `lab03-new.txt`.
4. Delete an existing blob.
5. Try the SAS workflow again and note what is different.
6. Open the storage account `Configuration` page and check `Allow storage account key access` again.

Create a simple comparison table for yourself:

- action
- worked in State A
- worked in State B
- error message if it failed

Expected State B result:

- list may still work
- read/download may still work
- upload fails
- delete fails
- SAS workflow that depends on shared key access is blocked or no longer available in the same way
- key access is disabled

## Compare State A and State B

### Step 9 - Explain what changed

Answer these questions before fixing anything:

1. Which actions worked in State A but failed in State B?
2. Which actions still worked in State B?
3. Which actions are read actions?
4. Which actions are write or delete actions?

This comparison is the most important part of the lab.

## Diagnose the cause

### Step 10 - Check IAM

In Azure Portal:

1. Open the storage account.
2. Go to `Access control (IAM)`.
3. Review your role assignments at storage account scope.
4. Identify that your blob data role is `Storage Blob Data Reader`.

### Step 11 - Understand the change

This lab changes two things:

1. your blob data role is reduced from contributor to reader
2. shared key access is disabled

That means:

- Entra ID RBAC still controls your normal Portal blob actions
- shared-key based SAS creation is no longer available in the same way

What shared key access means:

- Azure Storage can authorize requests by using the storage account key
- many SAS tokens are created by using that key
- if shared key access is disabled, key-based SAS workflows stop working

Why many companies disable it:

- they prefer Entra ID authentication
- they prefer RBAC-based access control
- they want less dependence on long-lived account keys
- account keys are very powerful, so many teams reduce their use

To see this in Portal in State B:

1. Open the storage account
2. Open `Configuration`
3. Find `Allow storage account key access`
4. In State B, it is disabled

### Step 12 - Fix the problem

In Azure Portal:

1. Open storage account `Access control (IAM)`.
2. Add the role `Storage Blob Data Contributor`.
3. Assign it to your user account at storage account scope.
4. Wait a few minutes for RBAC propagation.

### Step 13 - Verify the restored state

Retry the failed actions in the `labs` container.

Expected restored result:

- upload succeeds
- delete succeeds
- you can explain why the role change fixed the problem

## Questions to answer

1. Which actions worked in State A but failed in State B?
2. Which actions still worked in State B, and why?
3. Why does `Storage Blob Data Reader` allow list/read but not upload/delete?
4. Why did SAS behavior change in State B?
5. Which exact role and scope fixed the problem?

## Success criteria

- you reproduce failure in State B
- you identify missing blob data permissions as the root cause
- you restore write/delete capability by assigning `Storage Blob Data Contributor` at the correct scope
- you can explain read vs write/delete permissions clearly
- you can explain control plane vs data plane in simple words

## Required evidence

- State A evidence: successful list/upload/delete or SAS workflow
- State B evidence: failed upload/delete with the exact error
- a simple comparison of which actions worked and failed
- IAM screenshot before fix: `Storage Blob Data Reader`
- IAM screenshot after fix: `Storage Blob Data Contributor`
- final evidence: successful upload/delete after fix

## Clean up when the lab is finished

When you finish the lab:

1. delete the test blob you uploaded if it still exists
2. return to your own computer terminal
3. destroy the environment to avoid extra Azure cost

Destroy the environment from the `platform` folder:

```bash
cd platform
terraform destroy -var-file=../labs/tfvars/lab03_storage_rbac.tfvars
```

Use the Lab 3 tfvars file for destroy because the current deployed state is the Lab 3 scenario.

