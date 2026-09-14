# SKYGRID Provider Integration Gateway v1 readiness

The SKYGRID Provider Integration Gateway is a controlled-pilot sandbox for the **SKYGRID Emergency Data On-Ramp**. It gives carriers, emergency partners, municipalities, infrastructure teams, and internal reviewers a clean way to submit emergency, outage, responder, routing, system-health, continuity, and network-operations signals.

## Safety boundary

This gateway is operator-assist, auditable, and fail-closed. It is not autonomous carrier control, production failover, device activation, private-data movement, custody, blockchain signing, broadcasting, or payment execution.

## Accepted data

The sandbox accepts general provider event metadata: `provider_id`, `event_type`, `source_region`, `severity`, `timestamp`, `ttl_seconds`, a flexible `signal` object, and optional proof metadata.

## Data not accepted

Do not send private customer records, precise personal location, credentials, secrets, production network-control commands, payment instructions, custody material, signing keys, or device-activation payloads.

## Proof-of-intake

Valid events receive a local deterministic proof-style response containing the request id, provider id, event type, proof hash, receipt timestamp, controlled-pilot mode, and safety flags. The proof confirms sandbox intake only; it does not prove external delivery or production action.

## Suggested pilot scope

Start with sandbox provider ids, synthetic outage-health events, limited event types, short TTLs, partner review of JSON receipts, and a weekly operator review of accepted and rejected samples.

## Next procurement steps

Review the OpenAPI draft, import the Postman collection, agree on pilot event types, define non-private test payloads, document audit ownership, and approve a no-autonomous-control test plan.
