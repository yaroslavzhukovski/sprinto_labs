# Lab 04 Answer Key - Public vs Private Storage Access

## Recommended instructor flow

1. Student deploys the healthy public baseline first:

```bash
cd platform
terraform apply -var-file=terraform.tfvars
```

2. Student observes public-mode behavior:
   - public network access is enabled
   - there is no private endpoint yet
   - there is no private DNS zone for storage yet
   - DNS from VM context resolves the storage account name to a public IP

3. Student applies the Lab 4 scenario:

```bash
cd platform
terraform apply -var-file=../labs/tfvars/lab04_private_endpoint_dns.tfvars
```

4. Student observes healthy private-mode behavior:
   - public storage access is disabled
   - private endpoint exists
   - private DNS zone exists
   - private DNS virtual network link exists
   - DNS from VM context resolves the storage account to the private path

5. Student manually removes the private DNS virtual network link and observes the effect.
6. Student restores the link and confirms the design works again.

## Expected observations

### Public baseline

- Storage uses public access.
- No storage private endpoint exists yet.
- No storage private DNS zone is required yet.
- `nslookup <storage-account-name>.blob.core.windows.net` from the VM resolves to a public IP.

### Healthy private mode

- Public storage access is disabled.
- A blob private endpoint exists and is approved.
- `privatelink.blob.core.windows.net` private DNS zone exists.
- The hub virtual network link used by VM1 exists.
- DNS from VM context resolves the storage account to the private path.

### After manual break

- The private endpoint still exists.
- The missing DNS virtual network link prevents correct private DNS behavior from the VM context.
- Access over the intended private path no longer works correctly until the link is restored.

## Main teaching point

This lab is not mainly about finding a hidden broken resource.

It is about understanding:

1. how public access differs from private access
2. which Azure components are needed for private access
3. why DNS matters even when the private endpoint resource already exists

## Correct diagnosis path

1. Confirm storage account public access setting.
2. Test DNS resolution from VM context in the public baseline and note that it resolves to a public IP.
3. Confirm private endpoint exists and is approved.
4. Confirm private DNS zone exists.
5. Confirm private DNS virtual network link exists in healthy mode.
6. Test DNS resolution from VM context in healthy private mode.
7. Remove the link and compare the result.
8. Restore the link and verify the private path again.

## Root cause after the manual break

The private endpoint resource still exists, but the VM can no longer use the private DNS zone correctly because the virtual network link is missing.

Result:

- the service name is no longer resolved correctly for private access from inside the virtual network
- the intended private access design no longer works

## Correct fix

1. Re-create or restore the virtual network link for `privatelink.blob.core.windows.net`.
2. Re-test DNS from VM context.
3. Confirm the storage account name resolves correctly for private access again.

## Required evidence

- Screenshot of public baseline networking state.
- `nslookup` output from VM context in State A showing public-IP resolution.
- Screenshot of private endpoint with approved status.
- Screenshot of the private DNS zone.
- Screenshot of the private DNS virtual network link in healthy mode.
- `nslookup` or `dig` output from VM context in healthy private mode.
- Screenshot after manual removal of the DNS link.
- `nslookup` or `dig` output showing changed behavior after the manual break.
- Screenshot showing the restored DNS link.

## Common mistakes

- Testing from a local laptop instead of from a VM inside the virtual network.
- Deleting the private endpoint instead of only removing the DNS virtual network link.
- Changing multiple components at once, which makes cause and effect harder to understand.
- Looking only at the private endpoint and forgetting that DNS is part of the design.
