# AVD Bicep

Infrastructure-as-code for deploying Azure Virtual Desktop environments.

# Structure

- main.bicep - subscription-scoped entry point
- parameters.example.bicepparam — example parameters; copy and edit per customer
- modules/ - per-resource modules

# Status

Chunk 1 complete: foundation networking (4 VNets, subnets, peerings) and FSLogix storage account.
Validated via what-if; not yet deployed.

Next: chunk 2 - Log Analytics workspace and base diagnostic settings.

# Deploy

az deployment sub create `
  --location <region> `
  --name "avd-foundation-$(Get-Date -Format 'yyyyMMdd-HHmm')" `
  --template-file main.bicep `
  --parameters parameters.example.bicepparam

Customer-specific deployments should use a copy of parameters.example.bicepparam named parameters.<customer>.bicepparam (gitignored).
