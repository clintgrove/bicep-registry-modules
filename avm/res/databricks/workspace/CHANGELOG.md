# Changelog

The latest version of the changelog can be found [here](https://github.com/Azure/bicep-registry-modules/blob/main/avm/res/databricks/workspace/CHANGELOG.md).

## 0.11.4

### Changes

Added missing key resource: Created cMKManagedDiskKey resource within the shared cMKKeyVault to properly reference the managed disk key when both keys are in the same vault.

Fixed key version logic: Updated the managed disk encryption configuration to:

First check if an explicit keyVersion is provided
If not, use the correct key reference based on the Key Vault configuration
Use cMKKeyVault::cMKManagedDiskKey when keys are in the same vault
Maintained consistency: Applied the same pattern used for managed services encryption (check explicit version first, then fallback to key URI extraction).

### Breaking Changes

- None

## 0.11.3

### Changes

- Updated LockType to 'avm-common-types version' `0.6.0`, enabling custom notes for locks.
- Added type to `locks` parameter

### Breaking Changes

- None

## 0.11.2

### Changes

- Initial version
- Updated ReadMe with AzAdvertizer reference

### Breaking Changes

- None
