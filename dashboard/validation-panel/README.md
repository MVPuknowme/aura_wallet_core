# Validation panel

Required checks before execution:

- `helm lint helm/aura-core-autodrill`
- `helm template aura-core-autodrill helm/aura-core-autodrill --namespace aura-core`
- `kubectl apply --dry-run=server -f <rendered-manifest.yaml>`
- `node scripts/l2/prepareRoute.js --review-only`

Operators should attach command output to release evidence before signing.
