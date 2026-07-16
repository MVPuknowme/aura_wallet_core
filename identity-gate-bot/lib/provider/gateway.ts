import { createHash } from 'crypto';
import registry from '@/fixtures/provider-registry.json';

export const PROVIDER_GATEWAY_MODE = 'controlled_pilot';
export const PROVIDER_GATEWAY_NAME = 'SKYGRID Emergency Data On-Ramp';

export const safetyPosture = {
  operator_assist: true,
  autonomous_control: false,
  production_failover: false,
  private_data_movement: false,
  device_activation: false,
  payment_execution: false,
};

type Provider = {
  provider_id: string;
  display_name: string;
  environment: 'sandbox' | 'pilot' | 'production';
  allowed_event_types: string[];
  rate_limit_plan: string;
  status: string;
  created_at: string;
};

export type ProviderEvent = {
  provider_id: string;
  event_type: string;
  source_region: string;
  severity: 'info' | 'warning' | 'critical';
  timestamp: string;
  ttl_seconds: number;
  signal: Record<string, unknown>;
  proof?: {
    request_id?: string;
    hash?: string;
  };
};

export const providers = registry as Provider[];

export function providerStatus() {
  return {
    ok: true,
    name: PROVIDER_GATEWAY_NAME,
    mode: PROVIDER_GATEWAY_MODE,
    provider_count: providers.length,
    providers: providers.map(({ provider_id, display_name, environment, allowed_event_types, rate_limit_plan, status, created_at }) => ({
      provider_id,
      display_name,
      environment,
      allowed_event_types,
      rate_limit_plan,
      status,
      created_at,
    })),
    safety: safetyPosture,
  };
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

export function validateProviderEvent(value: unknown): { ok: true; event: ProviderEvent; provider: Provider } | { ok: false; errors: string[] } {
  const errors: string[] = [];
  if (!isObject(value)) return { ok: false, errors: ['body must be a JSON object'] };
  const provider = providers.find((item) => item.provider_id === value.provider_id);
  if (!provider) errors.push('provider_id is not registered for the controlled pilot sandbox');
  if (typeof value.event_type !== 'string' || value.event_type.length < 3) errors.push('event_type is required');
  if (provider && typeof value.event_type === 'string' && !provider.allowed_event_types.includes(value.event_type)) errors.push('event_type is not allowed for provider_id');
  if (typeof value.source_region !== 'string' || value.source_region.length < 2) errors.push('source_region is required');
  if (!['info', 'warning', 'critical'].includes(String(value.severity))) errors.push('severity must be info, warning, or critical');
  if (typeof value.timestamp !== 'string' || Number.isNaN(Date.parse(value.timestamp))) errors.push('timestamp must be an ISO-8601 string');
  if (typeof value.ttl_seconds !== 'number' || value.ttl_seconds < 60 || value.ttl_seconds > 86400) errors.push('ttl_seconds must be between 60 and 86400');
  if (!isObject(value.signal)) errors.push('signal must be a JSON object');
  if (value.proof !== undefined && !isObject(value.proof)) errors.push('proof must be a JSON object when provided');
  if (errors.length || !provider) return { ok: false, errors };
  return { ok: true, event: value as ProviderEvent, provider };
}

export function buildProofHash(event: Pick<ProviderEvent, 'provider_id' | 'event_type' | 'source_region' | 'severity' | 'timestamp' | 'ttl_seconds' | 'signal'>, requestId: string) {
  return `sha256:${createHash('sha256').update(JSON.stringify({ requestId, event })).digest('hex')}`;
}

export function proofForRequest(requestId: string) {
  const receivedAt = new Date().toISOString();
  return {
    ok: true,
    mode: PROVIDER_GATEWAY_MODE,
    request_id: requestId,
    proof_hash: `sha256:${createHash('sha256').update(`skygrid-provider-proof:${requestId}`).digest('hex')}`,
    received_at: receivedAt,
    deterministic_sandbox_response: true,
    safety: safetyPosture,
  };
}

export function acceptProviderEvent(event: ProviderEvent) {
  const requestId = event.proof?.request_id || `${event.provider_id}-${createHash('sha256').update(JSON.stringify(event)).digest('hex').slice(0, 16)}`;
  return {
    ok: true,
    mode: PROVIDER_GATEWAY_MODE,
    accepted: true,
    request_id: requestId,
    provider_id: event.provider_id,
    event_type: event.event_type,
    proof_hash: event.proof?.hash?.startsWith('sha256:') ? event.proof.hash : buildProofHash(event, requestId),
    received_at: new Date().toISOString(),
    safety: safetyPosture,
  };
}
