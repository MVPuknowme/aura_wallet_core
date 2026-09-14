# Aura-Core SkyGrid Command Center

The command center is the dashboard-first control surface for Aura-Core / SkyGrid operators. It prepares Helm, Kubernetes, and L2 JavaScript artifacts for review before any signing or submission step.

## Flow

1. Draft generated Helm values, Kubernetes manifests, and L2 route intents.
2. Validate with lint, template render, dependency checks, and dry-run commands.
3. Package deployable artifacts with human-readable operator summaries.
4. Execute only after explicit wallet/Web3 approval.

No wallet signing is automatic from the dashboard.
