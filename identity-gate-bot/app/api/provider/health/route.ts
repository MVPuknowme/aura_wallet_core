import { NextResponse } from 'next/server';
import { PROVIDER_GATEWAY_MODE, PROVIDER_GATEWAY_NAME, safetyPosture } from '@/lib/provider/gateway';

export async function GET() {
  return NextResponse.json({
    ok: true,
    name: PROVIDER_GATEWAY_NAME,
    mode: PROVIDER_GATEWAY_MODE,
    status: 'healthy',
    safety: safetyPosture,
  });
}
