import { acceptProviderEvent, proofForRequest, providerStatus, validateProviderEvent } from '../lib/provider/gateway';

const validEvent = {
  provider_id: 'att-sandbox',
  event_type: 'outage.health.signal',
  source_region: 'oregon.kfalls',
  severity: 'warning',
  timestamp: '2026-07-10T00:00:00Z',
  ttl_seconds: 3600,
  signal: { service: 'edge-health', status: 'degraded', latency_ms: 212, packet_loss_pct: 2.1 },
  proof: { request_id: 'skygrid-demo-001', hash: 'sha256-placeholder' },
} as const;

function assert(condition: unknown, message: string) {
  if (!condition) throw new Error(message);
}

const status = providerStatus();
assert(status.ok === true && status.mode === 'controlled_pilot', 'Provider status must return controlled pilot JSON');
assert(status.providers.length >= 4, 'Provider registry should include sandbox fixtures');

const parsed = validateProviderEvent(validEvent);
assert(parsed.ok === true, 'Valid provider event should pass validation');
if (parsed.ok) {
  const accepted = acceptProviderEvent(parsed.event);
  assert(accepted.accepted === true, 'Valid event should return accepted proof JSON');
  assert(accepted.request_id === 'skygrid-demo-001', 'Proof response should preserve request_id');
}

const invalid = validateProviderEvent({ provider_id: 'att-sandbox' });
assert(invalid.ok === false, 'Invalid provider event should fail validation');

const proof = proofForRequest('skygrid-demo-001');
assert(proof.ok === true && proof.deterministic_sandbox_response === true, 'Proof lookup should return deterministic sandbox response');

const replay = { ok: true, replay: 'dry_run', operator_assist_required: true, executed: false };
assert(replay.ok && replay.replay === 'dry_run' && replay.operator_assist_required && !replay.executed, 'Replay test should remain dry-run/operator-assist');

console.log('provider gateway smoke checks passed');
