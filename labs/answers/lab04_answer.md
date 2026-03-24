# Lab 04 Answer Key - Private Endpoint and DNS

## Expected symptom

- Storage public network access disabled.
- Access attempts fail due to DNS resolving public endpoint path or incorrect private DNS linkage.

## Correct diagnosis path

1. Confirm storage account network settings.
2. Check private endpoint provisioning/connection state.
3. Validate private DNS zone and virtual network link.
4. Resolve storage hostname from VM context and confirm private IP target.

## Root cause

With private endpoint lab flags enabled and DNS break enabled, private DNS integration is intentionally incomplete.

## Fix

1. Ensure `privatelink.blob.core.windows.net` private DNS zone exists.
2. Link zone to spoke VNet.
3. Ensure private endpoint has DNS zone group association.
4. Re-test name resolution and blob operations.

## Required evidence

- Private endpoint screenshot with approved status.
- DNS zone link screenshot.
- `nslookup`/`dig` output showing private IP resolution.
- Successful blob operation output.

## Common mistakes

- Fixing only private endpoint without DNS linkage.
- Testing from local laptop instead of in-VNet VM context.

