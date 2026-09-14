import { NextResponse } from 'next/server';
import { PROVIDER_GATEWAY_MODE, PROVIDER_GATEWAY_NAME, safetyPosture } from '@/lib/provider/gateway';

export async function POST() {
  return NextResponse.json({
    ok: true,
    name: PROVIDER_GATEWAY_NAME,
    mode: PROVIDER_GATEWAY_MODE,
    replay: 'dry_run',
    operator_assist_required: true,
    executed: false,
    message: 'Replay test validates intake shape only; it does not activate devices, move private data, fail over production systems, or execute payments.',
    safety: safetyPosture,
  });
}
