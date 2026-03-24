# Lab 04 - Private Endpoint and DNS

## Scenario

Storage account public network is disabled and private endpoint mode is expected. DNS is intentionally misconfigured, so clients resolve the wrong endpoint.

## Learning objectives

- Understand private endpoint data path.
- Validate DNS zone links and A records.
- Troubleshoot name resolution from VM context.

## Student tasks

1. Confirm storage public access is disabled.
2. Check private endpoint connection state.
3. Validate private DNS zone `privatelink.blob.core.windows.net` and VNet link.
4. Resolve DNS from VM and verify it maps to private IP.
5. Re-test blob operations.

## Success criteria

- Name resolution points to private endpoint IP.
- Blob operations succeed over private path.
